const { buildApprovedThreadPreview } = require('./workflow_helpers');

function buildJoinRequestCreatedNotification() {
  return {
    title: 'New join request',
    body: 'Someone wants to join your plan.',
  };
}

function buildJoinRequestRejectedNotification() {
  return {
    title: 'Plan request update',
    body: 'Your join request was not approved this time.',
  };
}

function buildJoinRequestApprovedNotification() {
  return {
    title: 'Your plan request was approved',
    body: 'You can now coordinate the meetup in chat.',
  };
}

function buildMessageCreatedNotification(textPreview) {
  return {
    title: 'New coordination message',
    body: textPreview,
  };
}

function buildApprovedThreadDocument({ threadId, activityId, participantIds }) {
  return {
    id: threadId,
    activityId,
    participantIds,
    lastMessagePreview: buildApprovedThreadPreview(),
    safetyBannerVisible: true,
    createdAt: '<server-timestamp>',
    updatedAt: '<server-timestamp>',
  };
}

module.exports = {
  buildApprovedThreadDocument,
  buildJoinRequestApprovedNotification,
  buildJoinRequestCreatedNotification,
  buildJoinRequestRejectedNotification,
  buildMessageCreatedNotification,
};
