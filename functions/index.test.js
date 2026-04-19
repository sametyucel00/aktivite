const test = require('node:test');
const assert = require('node:assert/strict');
const {
  getJoinApprovalOutcome,
  hasJoinCapacity,
  isActiveBlockData,
  isAllowedReportReason,
  isInvalidMessagingTokenCode,
  isValidUserAction,
  safeNotificationPreview,
  stringifyData,
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

test('isAllowedReportReason only accepts canonical reasons', () => {
  assert.equal(isAllowedReportReason('harassment'), true);
  assert.equal(isAllowedReportReason('unknown'), false);
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
