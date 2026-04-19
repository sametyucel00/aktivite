const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');

initializeApp();

const db = getFirestore();

exports.onJoinRequestCreated = onDocumentCreated(
  'activities/{activityId}/joinRequests/{requestId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const { activityId, requestId } = event.params;
    const request = snapshot.data();
    const activitySnapshot = await db.collection('activities').doc(activityId).get();
    if (!activitySnapshot.exists) {
      logger.warn('Join request references missing activity.', { activityId, requestId });
      await snapshot.ref.update({
        workflowStatus: 'invalidMissingActivity',
        updatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    const activity = activitySnapshot.data();
    if (activity.ownerUserId === request.requesterId) {
      logger.warn('Owner attempted to join own activity.', { activityId, requestId });
      await snapshot.ref.update({
        status: 'cancelled',
        workflowStatus: 'invalidOwnerRequest',
        updatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    logger.info('Join request created; owner notification fanout pending.', {
      activityId,
      requestId,
      ownerUserId: activity.ownerUserId,
      requesterId: request.requesterId,
    });
  },
);

exports.onJoinRequestStatusUpdated = onDocumentUpdated(
  'activities/{activityId}/joinRequests/{requestId}',
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (before.status === after.status) {
      return;
    }

    const { activityId, requestId } = event.params;
    if (before.status !== 'pending') {
      logger.warn('Ignoring non-pending join request transition.', {
        activityId,
        requestId,
        beforeStatus: before.status,
        afterStatus: after.status,
      });
      return;
    }

    if (after.status === 'approved') {
      await handleJoinRequestApproved({ activityId, requestId, request: after });
      return;
    }

    if (after.status === 'rejected') {
      logger.info('Join request rejected; requester notification pending.', {
        activityId,
        requestId,
        requesterId: after.requesterId,
      });
      await event.data.after.ref.update({
        workflowStatus: 'closedRejected',
        updatedAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    if (after.status === 'cancelled') {
      await event.data.after.ref.update({
        workflowStatus: 'closedCancelled',
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  },
);

exports.onReportCreated = onDocumentCreated('reports/{reportId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    return;
  }

  const report = snapshot.data();
  await db.collection('moderationEvents').add({
    subjectUserId: report.targetUserId,
    reasonCode: 'report_created',
    reason: report.reason || 'User report created',
    isUserVisible: false,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
    reportId: event.params.reportId,
  });
});

exports.onBlockCreated = onDocumentCreated('blocks/{blockId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    return;
  }

  const block = snapshot.data();
  logger.info('Block created; visibility suppression pending.', {
    blockId: event.params.blockId,
    userId: block.userId,
    targetUserId: block.targetUserId,
  });
});

exports.onMessageCreated = onDocumentCreated(
  'chatThreads/{threadId}/messages/{messageId}',
  async (event) => {
    const message = event.data && event.data.data();
    if (!message) {
      return;
    }

    logger.info('Message created; notification and moderation hooks pending.', {
      threadId: event.params.threadId,
      messageId: event.params.messageId,
      senderUserId: message.senderUserId,
    });
  },
);

async function handleJoinRequestApproved({ activityId, requestId, request }) {
  const activityRef = db.collection('activities').doc(activityId);
  const activitySnapshot = await activityRef.get();
  if (!activitySnapshot.exists) {
    logger.warn('Approved join request references missing activity.', { activityId, requestId });
    return;
  }

  const activity = activitySnapshot.data();
  const participantIds = [activity.ownerUserId, request.requesterId].filter(Boolean).sort();
  const threadId = `activity-${activityId}-${request.requesterId}`;
  const threadRef = db.collection('chatThreads').doc(threadId);

  await db.runTransaction(async (transaction) => {
    const latestActivity = await transaction.get(activityRef);
    const latestData = latestActivity.data();
    const participantCount = Math.min(
      (latestData.participantCount || 0) + 1,
      latestData.maxParticipants || 1,
    );

    transaction.update(activityRef, {
      participantCount,
      status: participantCount >= (latestData.maxParticipants || 1) ? 'full' : latestData.status,
      workflowSource: 'cloudFunction',
      updatedAt: FieldValue.serverTimestamp(),
    });

    transaction.set(
      threadRef,
      {
        id: threadId,
        activityId,
        participantIds,
        lastMessagePreview: 'Join request approved. Coordinate the meetup safely.',
        safetyBannerVisible: true,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });

  logger.info('Join request approved side effects completed.', {
    activityId,
    requestId,
    threadId,
  });
}
