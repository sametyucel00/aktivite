const test = require('node:test');
const assert = require('node:assert/strict');
const {
  buildApprovedThreadDocument,
  buildReportModerationReasonCode,
  buildBlockedPairIds,
  buildOwnerInvalidApprovalUpdate,
  buildApprovalSideEffectsCompletedUpdate,
  buildClosedJoinRequestUpdate,
  buildInvalidPayloadUpdate,
  buildJoinRequestApprovedNotificationData,
  buildJoinRequestCreatedNotificationData,
  buildJoinRequestRejectedNotificationData,
  buildMessageCreatedNotificationData,
  buildApprovedThreadId,
  buildApprovedThreadPreview,
  buildJoinRequestApprovedNotification,
  buildApprovedParticipantIds,
  collectInvalidTokenRefs,
  getJoinApprovalOutcome,
  getThreadRecipientIds,
  hasJoinCapacity,
  hasApprovedJoinStatus,
  hasApprovedSideEffectsCompleted,
  isActiveBlockData,
  isAllowedReportReason,
  isInvalidMessagingTokenCode,
  isTokenNormalizationNoop,
  isValidBlockPayload,
  isValidReportPayload,
  isValidUserAction,
  hasThreadParticipant,
  mapTokenDocs,
  normalizeNotificationTokenRecord,
  safeNotificationPreview,
  shouldDeleteNormalizedToken,
  stringifyData,
  uniqueUserIds,
  buildJoinRequestCreatedNotification,
  buildJoinRequestRejectedNotification,
  buildMessageCreatedNotification,
} = require('./helpers');

test('isValidUserAction rejects self-targeted and blank actions', () => {
  assert.equal(isValidUserAction({ userId: 'a', targetUserId: 'a' }), false);
  assert.equal(isValidUserAction({ userId: ' ', targetUserId: 'b' }), false);
  assert.equal(isValidUserAction({ userId: 'a', targetUserId: 'b' }), true);
});

test('safeNotificationPreview trims and clamps long messages', () => {
  assert.equal(safeNotificationPreview('   '), 'You have a new coordination message.');
  assert.equal(safeNotificationPreview(' hello '), 'hello');
  assert.equal(safeNotificationPreview(null), 'You have a new coordination message.');
  assert.equal(safeNotificationPreview('a'.repeat(81)).length, 80);
});

test('stringifyData coerces values into strings', () => {
  assert.deepEqual(stringifyData({ count: 2, flag: true }), {
    count: '2',
    flag: 'true',
  });
  assert.deepEqual(stringifyData(), {});
});

test('normalizeNotificationTokenRecord trims token and defaults platform', () => {
  assert.deepEqual(normalizeNotificationTokenRecord({ token: ' abc ', platform: '' }), {
    token: 'abc',
    platform: 'unknown',
    normalizedByFunction: true,
  });
});

test('isTokenNormalizationNoop matches already-normalized writes', () => {
  assert.equal(
    isTokenNormalizationNoop(
      { token: 'abc', platform: 'android', normalizedByFunction: true },
      { token: 'abc', platform: 'android', normalizedByFunction: true },
    ),
    true,
  );
  assert.equal(
    isTokenNormalizationNoop(
      { token: 'abc', platform: 'android', normalizedByFunction: true },
      { token: 'def', platform: 'android', normalizedByFunction: true },
    ),
    false,
  );
});

test('uniqueUserIds de-duplicates and drops falsy values', () => {
  assert.deepEqual(uniqueUserIds(['a', 'b', 'a', '', null]), ['a', 'b']);
});

test('buildBlockedPairIds returns both block directions', () => {
  assert.deepEqual(buildBlockedPairIds('owner', 'guest'), [
    'owner-guest',
    'guest-owner',
  ]);
});

test('workflow helpers build deterministic metadata payloads', () => {
  assert.deepEqual(buildInvalidPayloadUpdate('invalidReportPayload'), {
    workflowStatus: 'invalidReportPayload',
    updatedAt: '<server-timestamp>',
  });
  assert.deepEqual(buildClosedJoinRequestUpdate('rejected'), {
    workflowStatus: 'closedRejected',
    updatedAt: '<server-timestamp>',
  });
  assert.equal(buildApprovedThreadId('activity-1', 'guest-1'), 'activity-activity-1-guest-1');
  assert.equal(
    buildApprovedThreadPreview(),
    'Join request approved. Coordinate the meetup safely.',
  );
  assert.deepEqual(buildOwnerInvalidApprovalUpdate(), {
    status: 'cancelled',
    workflowStatus: 'invalidOwnerRequest',
    updatedAt: '<server-timestamp>',
  });
  assert.deepEqual(buildApprovalSideEffectsCompletedUpdate(), {
    workflowStatus: 'approvalSideEffectsCompleted',
    updatedAt: '<server-timestamp>',
  });
});

test('notification payload helpers build stable title and body copy', () => {
  assert.deepEqual(buildJoinRequestCreatedNotification(), {
    title: 'New join request',
    body: 'Someone wants to join your plan.',
  });
  assert.deepEqual(buildJoinRequestRejectedNotification(), {
    title: 'Plan request update',
    body: 'Your join request was not approved this time.',
  });
  assert.deepEqual(buildJoinRequestApprovedNotification(), {
    title: 'Your plan request was approved',
    body: 'You can now coordinate the meetup in chat.',
  });
  assert.deepEqual(buildMessageCreatedNotification('See you soon'), {
    title: 'New coordination message',
    body: 'See you soon',
  });
});

test('notification payload helpers build approved thread documents', () => {
  assert.deepEqual(
    buildApprovedThreadDocument({
      threadId: 'thread-1',
      activityId: 'activity-1',
      participantIds: ['guest', 'owner'],
    }),
    {
      id: 'thread-1',
      activityId: 'activity-1',
      participantIds: ['guest', 'owner'],
      lastMessagePreview: buildApprovedThreadPreview(),
      safetyBannerVisible: true,
      createdAt: '<server-timestamp>',
      updatedAt: '<server-timestamp>',
    },
  );
});

test('workflow helpers build notification payloads', () => {
  assert.deepEqual(
    buildJoinRequestCreatedNotificationData({
      activityId: 'activity-1',
      requestId: 'guest-1',
    }),
    {
      type: 'join_request_created',
      activityId: 'activity-1',
      requestId: 'guest-1',
    },
  );
  assert.deepEqual(
    buildJoinRequestRejectedNotificationData({
      activityId: 'activity-1',
      requestId: 'guest-1',
    }),
    {
      type: 'join_request_rejected',
      activityId: 'activity-1',
      requestId: 'guest-1',
    },
  );
  assert.deepEqual(
    buildJoinRequestApprovedNotificationData({
      activityId: 'activity-1',
      requestId: 'guest-1',
      threadId: 'thread-1',
    }),
    {
      type: 'join_request_approved',
      activityId: 'activity-1',
      requestId: 'guest-1',
      threadId: 'thread-1',
    },
  );
  assert.deepEqual(
    buildMessageCreatedNotificationData({
      threadId: 'thread-1',
      messageId: 'message-1',
    }),
    {
      type: 'message_created',
      threadId: 'thread-1',
      messageId: 'message-1',
    },
  );
});

test('mapTokenDocs trims tokens and drops blanks', () => {
  const docs = [
    {
      ref: { path: 'users/a/token/1' },
      data: () => ({ token: ' abc ' }),
    },
    {
      ref: { path: 'users/a/token/2' },
      data: () => ({ token: '   ' }),
    },
  ];
  assert.deepEqual(mapTokenDocs(docs), [
    { ref: docs[0].ref, token: 'abc' },
  ]);
});

test('thread recipient helpers validate membership and exclude sender', () => {
  assert.equal(hasThreadParticipant(['owner', 'guest'], 'guest'), true);
  assert.equal(hasThreadParticipant(['owner', 'guest'], 'other'), false);
  assert.deepEqual(getThreadRecipientIds(['owner', 'guest'], 'guest'), ['owner']);
  assert.deepEqual(getThreadRecipientIds(null, 'guest'), []);
});

test('collectInvalidTokenRefs returns refs for invalid token responses only', () => {
  const tokenRecords = [{ ref: { id: '1' } }, { ref: { id: '2' } }];
  const refs = collectInvalidTokenRefs(
    tokenRecords,
    [
      { error: { code: 'messaging/registration-token-not-registered' } },
      { error: { code: 'messaging/internal-error' } },
    ],
    isInvalidMessagingTokenCode,
  );
  assert.deepEqual(refs, [{ id: '1' }]);
});

test('shouldDeleteNormalizedToken matches empty normalized tokens', () => {
  assert.equal(shouldDeleteNormalizedToken({ token: '' }), true);
  assert.equal(shouldDeleteNormalizedToken({ token: 'abc' }), false);
});

test('join approval outcome blocks owner, full, and cancelled activities', () => {
  assert.deepEqual(
    getJoinApprovalOutcome({
      activity: {
        ownerUserId: 'owner',
        participantCount: 1,
        maxParticipants: 4,
        status: 'open',
      },
      request: { requesterId: 'owner' },
    }),
    {
      allowSideEffects: false,
      workflowStatus: 'invalidOwnerRequest',
      nextStatus: 'cancelled',
    },
  );

  assert.deepEqual(
    getJoinApprovalOutcome({
      activity: {
        ownerUserId: 'owner',
        participantCount: 4,
        maxParticipants: 4,
        status: 'open',
      },
      request: { requesterId: 'guest' },
    }),
    {
      allowSideEffects: false,
      workflowStatus: 'approvalCapacityBlocked',
    },
  );
});

test('join approval outcome allows normal side effects', () => {
  assert.deepEqual(
    getJoinApprovalOutcome({
      activity: {
        ownerUserId: 'owner',
        participantCount: 1,
        maxParticipants: 4,
        status: 'open',
      },
      request: { requesterId: 'guest' },
    }),
    {
      allowSideEffects: true,
    },
  );
});

test('hasJoinCapacity reflects closed and full activities', () => {
  assert.equal(
    hasJoinCapacity({
      participantCount: 1,
      maxParticipants: 4,
      status: 'open',
    }),
    true,
  );
  assert.equal(
    hasJoinCapacity({
      participantCount: 4,
      maxParticipants: 4,
      status: 'open',
    }),
    false,
  );
  assert.equal(hasJoinCapacity({ status: 'cancelled' }), false);
});

test('join helpers build sorted participant ids and detect completed side effects', () => {
  assert.deepEqual(buildApprovedParticipantIds('owner', 'guest'), ['guest', 'owner']);
  assert.equal(hasApprovedJoinStatus({ status: 'approved' }), true);
  assert.equal(hasApprovedJoinStatus({ status: 'pending' }), false);
  assert.equal(
    hasApprovedSideEffectsCompleted({
      workflowStatus: 'approvalSideEffectsCompleted',
    }),
    true,
  );
  assert.equal(hasApprovedSideEffectsCompleted({ workflowStatus: 'pending' }), false);
});

test('isAllowedReportReason only accepts canonical reasons', () => {
  assert.equal(isAllowedReportReason('harassment'), true);
  assert.equal(isAllowedReportReason('unknown'), false);
});

test('safety payload helpers validate report and block payloads', () => {
  assert.equal(
    isValidReportPayload({
      userId: 'reporter',
      targetUserId: 'guest',
      reason: 'harassment',
    }),
    true,
  );
  assert.equal(
    isValidReportPayload({
      userId: 'reporter',
      targetUserId: 'reporter',
      reason: 'harassment',
    }),
    false,
  );
  assert.equal(
    isValidBlockPayload({
      userId: 'owner',
      targetUserId: 'guest',
    }),
    true,
  );
});

test('buildReportModerationReasonCode returns canonical moderation code', () => {
  assert.equal(buildReportModerationReasonCode('spam'), 'report_spam');
  assert.equal(buildReportModerationReasonCode('unknown'), null);
});

test('join approval outcome rejects missing activity or request payloads', () => {
  assert.deepEqual(
    getJoinApprovalOutcome({
      activity: null,
      request: { requesterId: 'guest' },
    }),
    {
      allowSideEffects: false,
      workflowStatus: 'invalidMissingActivity',
    },
  );
});

test('invalid messaging token codes are recognized', () => {
  assert.equal(
    isInvalidMessagingTokenCode('messaging/registration-token-not-registered'),
    true,
  );
  assert.equal(isInvalidMessagingTokenCode('messaging/internal-error'), false);
});

test('active block data requires active status', () => {
  assert.equal(isActiveBlockData({ status: 'active' }), true);
  assert.equal(isActiveBlockData({ status: 'inactive' }), false);
  assert.equal(isActiveBlockData(null), false);
  assert.equal(isActiveBlockData({}), false);
});
