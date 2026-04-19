function uniqueUserIds(userIds) {
  return [...new Set((userIds || []).filter(Boolean))];
}

function buildBlockedPairIds(actorUserId, recipientId) {
  return [
    `${actorUserId}-${recipientId}`,
    `${recipientId}-${actorUserId}`,
  ];
}

function mapTokenDocs(docs) {
  return (docs || [])
    .map((doc) => ({
      ref: doc.ref,
      token: typeof doc.data().token === 'string' ? doc.data().token.trim() : '',
    }))
    .filter((record) => record.token);
}

function collectInvalidTokenRefs(tokenRecords, responses, isInvalidMessagingTokenCode) {
  const deletes = [];

  (responses || []).forEach((response, index) => {
    const code = response?.error?.code;
    if (code && isInvalidMessagingTokenCode(code)) {
      deletes.push(tokenRecords[index]?.ref);
    }
  });

  return deletes.filter(Boolean);
}

function shouldDeleteNormalizedToken(normalizedRecord) {
  return !normalizedRecord?.token;
}

module.exports = {
  buildBlockedPairIds,
  collectInvalidTokenRefs,
  mapTokenDocs,
  shouldDeleteNormalizedToken,
  uniqueUserIds,
};
