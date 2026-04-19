function isValidUserAction(action) {
  const userId = typeof action.userId === 'string' ? action.userId.trim() : '';
  const targetUserId =
    typeof action.targetUserId === 'string' ? action.targetUserId.trim() : '';
  return Boolean(userId && targetUserId && userId !== targetUserId);
}

function isActiveBlockData(data) {
  return Boolean(data) && data.status === 'active';
}

function isActiveBlock(snapshot) {
  return snapshot.exists && isActiveBlockData(snapshot.data());
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

function isInvalidMessagingTokenCode(code) {
  return new Set([
    'messaging/invalid-registration-token',
    'messaging/registration-token-not-registered',
  ]).has(code);
}

function getJoinApprovalOutcome({ activity, request }) {
  if (!activity || !request) {
    return { allowSideEffects: false, workflowStatus: 'invalidMissingActivity' };
  }

  if (activity.ownerUserId === request.requesterId) {
    return {
      allowSideEffects: false,
      workflowStatus: 'invalidOwnerRequest',
      nextStatus: 'cancelled',
    };
  }

  const currentParticipantCount = activity.participantCount || 0;
  const maxParticipants = activity.maxParticipants || 1;
  if (
    activity.status === 'full' ||
    activity.status === 'cancelled' ||
    activity.status === 'completed' ||
    currentParticipantCount >= maxParticipants
  ) {
    return {
      allowSideEffects: false,
      workflowStatus: 'approvalCapacityBlocked',
    };
  }

  return { allowSideEffects: true };
}

module.exports = {
  getJoinApprovalOutcome,
  isActiveBlock,
  isActiveBlockData,
  isInvalidMessagingTokenCode,
  isValidUserAction,
  safeNotificationPreview,
  stringifyData,
};
