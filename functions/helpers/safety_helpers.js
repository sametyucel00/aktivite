function isValidUserAction(action) {
  const userId = typeof action?.userId === 'string' ? action.userId.trim() : '';
  const targetUserId =
    typeof action?.targetUserId === 'string' ? action.targetUserId.trim() : '';
  return Boolean(userId && targetUserId && userId !== targetUserId);
}

function isActiveBlockData(data) {
  return Boolean(data) && data.status === 'active';
}

function isActiveBlock(snapshot) {
  return snapshot.exists && isActiveBlockData(snapshot.data());
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

function isValidReportPayload(report) {
  return isValidUserAction(report) && isAllowedReportReason(report?.reason);
}

function isValidBlockPayload(block) {
  return isValidUserAction(block);
}

module.exports = {
  buildReportModerationReasonCode,
  isActiveBlock,
  isActiveBlockData,
  isAllowedReportReason,
  isValidBlockPayload,
  isValidReportPayload,
  isValidUserAction,
};
