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

module.exports = {
  isInvalidMessagingTokenCode,
  isTokenNormalizationNoop,
  normalizeNotificationTokenRecord,
  safeNotificationPreview,
  stringifyData,
};
