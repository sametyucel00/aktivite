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

function normalizeNotificationTokenRecord(data) {
  const token = typeof data?.token === 'string' ? data.token.trim() : '';
  const platform =
    typeof data?.platform === 'string' && data.platform.trim()
      ? data.platform.trim()
      : 'unknown';
  return {
    token,
    platform,
    normalizedByFunction: true,
  };
}

function isTokenNormalizationNoop(before, normalizedAfter) {
  return Boolean(before) &&
    before.normalizedByFunction === true &&
    normalizedAfter.normalizedByFunction === true &&
    before.token === normalizedAfter.token &&
    before.platform === normalizedAfter.platform;
}

function isAllowedReportReason(reason) {
  return new Set([
    'spam',
    'harassment',
    'unsafe_meetup',
    'fake_profile',
    'inappropriate_content',
  ]).has(reason);
}

function buildReportModerationReasonCode(reason) {
  return isAllowedReportReason(reason) ? `report_${reason}` : null;
}

function hasJoinCapacity(activity) {
  const currentParticipantCount = activity?.participantCount || 0;
  const maxParticipants = activity?.maxParticipants || 1;
  return (
    activity &&
    activity.status !== 'full' &&
    activity.status !== 'cancelled' &&
    activity.status !== 'completed' &&
    currentParticipantCount < maxParticipants
  );
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

  if (!hasJoinCapacity(activity)) {
    return {
      allowSideEffects: false,
      workflowStatus: 'approvalCapacityBlocked',
    };
  }

  return { allowSideEffects: true };
}

module.exports = {
  buildReportModerationReasonCode,
  getJoinApprovalOutcome,
  hasJoinCapacity,
  isActiveBlock,
  isActiveBlockData,
  isAllowedReportReason,
  isInvalidMessagingTokenCode,
  isTokenNormalizationNoop,
  isValidUserAction,
  normalizeNotificationTokenRecord,
  safeNotificationPreview,
  stringifyData,
};
