function buildInvalidPayloadUpdate(workflowStatus) {
  return {
    workflowStatus,
    updatedAt: '<server-timestamp>',
  };
}

function buildClosedJoinRequestUpdate(status) {
  const workflowStatusByStatus = {
    rejected: 'closedRejected',
    cancelled: 'closedCancelled',
  };

  return {
    workflowStatus: workflowStatusByStatus[status] || 'closedUnknown',
    updatedAt: '<server-timestamp>',
  };
}

function buildApprovedThreadId(activityId, requesterId) {
  return `activity-${activityId}-${requesterId}`;
}

function buildApprovedThreadPreview() {
  return 'Join request approved. Coordinate the meetup safely.';
}

function buildJoinRequestCreatedNotificationData({ activityId, requestId }) {
  return {
    type: 'join_request_created',
    activityId,
    requestId,
  };
}

function buildJoinRequestRejectedNotificationData({ activityId, requestId }) {
  return {
    type: 'join_request_rejected',
    activityId,
    requestId,
  };
}

function buildJoinRequestApprovedNotificationData({
  activityId,
  requestId,
  threadId,
}) {
  return {
    type: 'join_request_approved',
    activityId,
    requestId,
    threadId,
  };
}

function buildMessageCreatedNotificationData({ threadId, messageId }) {
  return {
    type: 'message_created',
    threadId,
    messageId,
  };
}

module.exports = {
  buildApprovedThreadId,
  buildApprovedThreadPreview,
  buildClosedJoinRequestUpdate,
  buildInvalidPayloadUpdate,
  buildJoinRequestApprovedNotificationData,
  buildJoinRequestCreatedNotificationData,
  buildJoinRequestRejectedNotificationData,
  buildMessageCreatedNotificationData,
};
