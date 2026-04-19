const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const {
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentWritten,
} = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

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

    const ownerRecipients = await filterBlockedNotificationRecipients({
      actorUserId: request.requesterId,
      recipientIds: [activity.ownerUserId],
    });
    await sendNotificationToUsers({
      userIds: ownerRecipients,
      title: 'New join request',
      body: 'Someone wants to join your plan.',
      data: {
        type: 'join_request_created',
        activityId,
        requestId,
      },
    });

    logger.info('Join request created; owner notification fanout attempted.', {
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
      await handleJoinRequestApproved({
        activityId,
        requestId,
        request: after,
        requestRef: event.data.after.ref,
      });
      return;
    }

    if (after.status === 'rejected') {
      const activitySnapshot = await db.collection('activities').doc(activityId).get();
      const activity = activitySnapshot.exists ? activitySnapshot.data() : {};
      const requesterRecipients = await filterBlockedNotificationRecipients({
        actorUserId: activity.ownerUserId,
        recipientIds: [after.requesterId],
      });
      await sendNotificationToUsers({
        userIds: requesterRecipients,
        title: 'Plan request update',
        body: 'Your join request was not approved this time.',
        data: {
          type: 'join_request_rejected',
          activityId,
          requestId,
        },
      });

      logger.info('Join request rejected; requester notification attempted.', {
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
  if (!isValidUserAction(report)) {
    await snapshot.ref.update({
      workflowStatus: 'invalidReportPayload',
      updatedAt: FieldValue.serverTimestamp(),
    });
    logger.warn('Report created with invalid payload.', { reportId: event.params.reportId });
    return;
  }

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
  if (!isValidUserAction(block)) {
    await snapshot.ref.update({
      workflowStatus: 'invalidBlockPayload',
      updatedAt: FieldValue.serverTimestamp(),
    });
    logger.warn('Block created with invalid payload.', { blockId: event.params.blockId });
    return;
  }

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

    const threadSnapshot = await db.collection('chatThreads').doc(event.params.threadId).get();
    if (!threadSnapshot.exists) {
      logger.warn('Message references missing chat thread.', {
        threadId: event.params.threadId,
        messageId: event.params.messageId,
      });
      return;
    }

    const thread = threadSnapshot.data();
    if (!Array.isArray(thread.participantIds) || !thread.participantIds.includes(message.senderUserId)) {
      await event.data.ref.update({
        moderationStatus: 'invalidSender',
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.warn('Message sender is not a thread participant.', {
        threadId: event.params.threadId,
        messageId: event.params.messageId,
        senderUserId: message.senderUserId,
      });
      return;
    }

    const recipientIds = await filterBlockedNotificationRecipients({
      actorUserId: message.senderUserId,
      recipientIds: thread.participantIds.filter((userId) => userId !== message.senderUserId),
    });
    await sendNotificationToUsers({
      userIds: recipientIds,
      title: 'New coordination message',
      body: safeNotificationPreview(message.text),
      data: {
        type: 'message_created',
        threadId: event.params.threadId,
        messageId: event.params.messageId,
      },
    });

    logger.info('Message created; notification fanout attempted.', {
      threadId: event.params.threadId,
      messageId: event.params.messageId,
      senderUserId: message.senderUserId,
    });
  },
);

exports.onNotificationTokenWritten = onDocumentWritten(
  'users/{userId}/notificationTokens/{tokenId}',
  async (event) => {
    const before = event.data.before.exists ? event.data.before.data() : null;
    const after = event.data.after.exists ? event.data.after.data() : null;
    if (!after) {
      return;
    }

    const token = typeof after.token === 'string' ? after.token.trim() : '';
    const platform = typeof after.platform === 'string' ? after.platform : 'unknown';
    if (
      before &&
      before.normalizedByFunction === true &&
      after.normalizedByFunction === true &&
      before.token === token &&
      before.platform === platform
    ) {
      return;
    }

    if (!token) {
      await event.data.after.ref.delete();
      logger.warn('Deleted empty notification token.', event.params);
      return;
    }

    const normalized = {
      token,
      platform,
      normalizedByFunction: true,
      updatedAt: FieldValue.serverTimestamp(),
    };
    await event.data.after.ref.set(normalized, { merge: true });
  },
);

async function handleJoinRequestApproved({ activityId, requestId, request, requestRef }) {
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

  const sideEffectsApplied = await db.runTransaction(async (transaction) => {
    const latestRequest = await transaction.get(requestRef);
    if (!latestRequest.exists) {
      logger.warn('Approved join request disappeared before side effects.', {
        activityId,
        requestId,
      });
      return false;
    }

    const latestRequestData = latestRequest.data();
    if (latestRequestData.status !== 'approved') {
      logger.warn('Approved join request side effects skipped for stale status.', {
        activityId,
        requestId,
        status: latestRequestData.status,
      });
      return false;
    }

    if (latestRequestData.workflowStatus === 'approvalSideEffectsCompleted') {
      logger.info('Approved join request side effects already completed.', {
        activityId,
        requestId,
      });
      return false;
    }

    const latestActivity = await transaction.get(activityRef);
    if (!latestActivity.exists) {
      logger.warn('Approved join request activity disappeared before side effects.', {
        activityId,
        requestId,
      });
      return false;
    }

    const latestData = latestActivity.data();
    if (latestData.ownerUserId === latestRequestData.requesterId) {
      transaction.update(requestRef, {
        status: 'cancelled',
        workflowStatus: 'invalidOwnerRequest',
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.warn('Approved join request tried to approve the activity owner.', {
        activityId,
        requestId,
      });
      return false;
    }

    const currentParticipantCount = latestData.participantCount || 0;
    const maxParticipants = latestData.maxParticipants || 1;
    if (
      latestData.status === 'full' ||
      latestData.status === 'cancelled' ||
      latestData.status === 'completed' ||
      currentParticipantCount >= maxParticipants
    ) {
      transaction.update(requestRef, {
        workflowStatus: 'approvalCapacityBlocked',
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.warn('Approved join request skipped because activity is not joinable.', {
        activityId,
        requestId,
        activityStatus: latestData.status,
        participantCount: currentParticipantCount,
        maxParticipants,
      });
      return false;
    }

    const participantCount = Math.min(
      currentParticipantCount + 1,
      maxParticipants,
    );

    transaction.update(activityRef, {
      participantCount,
      status: participantCount >= maxParticipants ? 'full' : latestData.status,
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

    transaction.update(requestRef, {
      workflowStatus: 'approvalSideEffectsCompleted',
      updatedAt: FieldValue.serverTimestamp(),
    });

    return true;
  });

  if (!sideEffectsApplied) {
    return;
  }

  const requesterRecipients = await filterBlockedNotificationRecipients({
    actorUserId: activity.ownerUserId,
    recipientIds: [request.requesterId],
  });
  await sendNotificationToUsers({
    userIds: requesterRecipients,
    title: 'Your plan request was approved',
    body: 'You can now coordinate the meetup in chat.',
    data: {
      type: 'join_request_approved',
      activityId,
      requestId,
      threadId,
    },
  });

  logger.info('Join request approved side effects completed.', {
    activityId,
    requestId,
    threadId,
  });
}

async function sendNotificationToUsers({ userIds, title, body, data }) {
  const uniqueUserIds = [...new Set((userIds || []).filter(Boolean))];
  if (uniqueUserIds.length === 0) {
    return;
  }

  const tokenRecords = await collectNotificationTokens(uniqueUserIds);
  if (tokenRecords.length === 0) {
    logger.info('No notification tokens found for fanout.', { userIds: uniqueUserIds });
    return;
  }

  const response = await messaging.sendEachForMulticast({
    tokens: tokenRecords.map((record) => record.token),
    notification: {
      title,
      body,
    },
    data: stringifyData(data),
  });

  await cleanupInvalidTokens(tokenRecords, response.responses);
}

async function filterBlockedNotificationRecipients({ actorUserId, recipientIds }) {
  const uniqueRecipientIds = [...new Set((recipientIds || []).filter(Boolean))];
  if (!actorUserId || uniqueRecipientIds.length === 0) {
    return uniqueRecipientIds;
  }

  const checks = await Promise.all(
    uniqueRecipientIds.map(async (recipientId) => {
      const [actorBlockedRecipient, recipientBlockedActor] = await Promise.all([
        db.collection('blocks').doc(`${actorUserId}-${recipientId}`).get(),
        db.collection('blocks').doc(`${recipientId}-${actorUserId}`).get(),
      ]);

      return isActiveBlock(actorBlockedRecipient) || isActiveBlock(recipientBlockedActor)
        ? null
        : recipientId;
    }),
  );

  return checks.filter(Boolean);
}

function isActiveBlock(snapshot) {
  return snapshot.exists && snapshot.data().status === 'active';
}

function isValidUserAction(action) {
  const userId = typeof action.userId === 'string' ? action.userId.trim() : '';
  const targetUserId =
    typeof action.targetUserId === 'string' ? action.targetUserId.trim() : '';
  return Boolean(userId && targetUserId && userId !== targetUserId);
}

async function collectNotificationTokens(userIds) {
  const snapshots = await Promise.all(
    userIds.map((userId) =>
      db.collection('users').doc(userId).collection('notificationTokens').get(),
    ),
  );

  return snapshots.flatMap((snapshot) =>
    snapshot.docs
      .map((doc) => ({
        ref: doc.ref,
        token: typeof doc.data().token === 'string' ? doc.data().token.trim() : '',
      }))
      .filter((record) => record.token),
  );
}

async function cleanupInvalidTokens(tokenRecords, responses) {
  const invalidCodes = new Set([
    'messaging/invalid-registration-token',
    'messaging/registration-token-not-registered',
  ]);
  const deletes = [];

  responses.forEach((response, index) => {
    const code = response.error && response.error.code;
    if (code && invalidCodes.has(code)) {
      deletes.push(tokenRecords[index].ref.delete());
    }
  });

  if (deletes.length > 0) {
    await Promise.all(deletes);
    logger.info('Removed invalid notification tokens.', { count: deletes.length });
  }
}

function stringifyData(data) {
  return Object.fromEntries(
    Object.entries(data || {}).map(([key, value]) => [key, String(value)]),
  );
}

function safeNotificationPreview(text) {
  const normalized = typeof text === 'string' ? text.trim() : '';
  if (!normalized) {
    return 'You have a new coordination message.';
  }
  return normalized.length > 80 ? `${normalized.substring(0, 77)}...` : normalized;
}
