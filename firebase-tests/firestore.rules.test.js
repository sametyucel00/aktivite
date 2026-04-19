const test = require('node:test');
const assert = require('node:assert/strict');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const { doc, getDoc, setDoc, updateDoc } = require('firebase/firestore');
const {
  emulatorSkipReason,
  hasEmulatorRuntime,
  readFixture,
  readWorkspaceFile,
} = require('./helpers/runtime');

const runtimeReady = hasEmulatorRuntime();
const skip = runtimeReady ? false : emulatorSkipReason();
const projectId = 'nar-rehberi-rules-tests';

let testEnv;
let activityFixture;
let joinRequestFixture;
let chatThreadFixture;
let reportFixture;
let blockFixture;

async function seedFirestore(path, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

test.before(async () => {
  if (!runtimeReady) {
    return;
  }

  const [firestoreRules, activity, joinRequest, chatThread, report, block] = await Promise.all([
    readWorkspaceFile('firestore.rules'),
    readFixture('activity'),
    readFixture('join_request'),
    readFixture('chat_thread'),
    readFixture('report'),
    readFixture('block'),
  ]);

  activityFixture = activity;
  joinRequestFixture = joinRequest;
  chatThreadFixture = chatThread;
  reportFixture = report;
  blockFixture = block;

  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: firestoreRules,
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

test.beforeEach(async () => {
  if (!runtimeReady) {
    return;
  }

  await testEnv.clearFirestore();
});

test.after(async () => {
  if (!runtimeReady || !testEnv) {
    return;
  }

  await testEnv.cleanup();
});

test('allows owner to create activity fixture under own identity', { skip }, async () => {
  const ownerDb = testEnv.authenticatedContext('owner-1').firestore();
  await assertSucceeds(setDoc(doc(ownerDb, 'activities', 'activity-1'), activityFixture));

  const created = await getDoc(doc(ownerDb, 'activities', 'activity-1'));
  assert.equal(created.exists(), true);
});

test(
  'denies activity create payloads that expose exact location fields',
  { skip },
  async () => {
    const ownerDb = testEnv.authenticatedContext('owner-1').firestore();
    await assertFails(
      setDoc(doc(ownerDb, 'activities', 'activity-2'), {
        ...activityFixture,
        id: 'activity-2',
        exactLocation: '40.0,29.0',
      }),
    );
  },
);

test(
  'denies cross-user join request writes that break deterministic request ids',
  { skip },
  async () => {
    await seedFirestore('activities/activity-1', activityFixture);

    const guestDb = testEnv.authenticatedContext('guest-1').firestore();

    await assertSucceeds(
      setDoc(
        doc(guestDb, 'activities', 'activity-1', 'joinRequests', 'guest-1'),
        joinRequestFixture,
      ),
    );

    await assertFails(
      setDoc(
        doc(guestDb, 'activities', 'activity-1', 'joinRequests', 'not-guest-1'),
        joinRequestFixture,
      ),
    );
  },
);

test(
  'restricts join request updates to owner decisions and requester cancellation',
  { skip },
  async () => {
    await seedFirestore('activities/activity-1', activityFixture);
    await seedFirestore(
      'activities/activity-1/joinRequests/guest-1',
      joinRequestFixture,
    );

    const ownerDb = testEnv.authenticatedContext('owner-1').firestore();
    const guestDb = testEnv.authenticatedContext('guest-1').firestore();

    await assertSucceeds(
      updateDoc(doc(ownerDb, 'activities', 'activity-1', 'joinRequests', 'guest-1'), {
        status: 'approved',
        workflowStatus: 'approvalPending',
      }),
    );

    await seedFirestore(
      'activities/activity-1/joinRequests/guest-1',
      joinRequestFixture,
    );

    await assertSucceeds(
      updateDoc(doc(guestDb, 'activities', 'activity-1', 'joinRequests', 'guest-1'), {
        status: 'cancelled',
        workflowStatus: 'closedCancelled',
      }),
    );

    await seedFirestore(
      'activities/activity-1/joinRequests/guest-1',
      joinRequestFixture,
    );

    await assertFails(
      updateDoc(doc(guestDb, 'activities', 'activity-1', 'joinRequests', 'guest-1'), {
        message: 'Changed copy',
      }),
    );
  },
);

test(
  'denies chat-thread creation from clients and allows participant message writes only',
  { skip },
  async () => {
    const guestDb = testEnv.authenticatedContext('guest-1').firestore();
    const outsiderDb = testEnv.authenticatedContext('outsider-1').firestore();

    await assertFails(setDoc(doc(guestDb, 'chatThreads', 'thread-1'), chatThreadFixture));

    await seedFirestore('chatThreads/thread-1', chatThreadFixture);

    await assertSucceeds(
      setDoc(doc(guestDb, 'chatThreads', 'thread-1', 'messages', 'message-1'), {
        threadId: 'thread-1',
        senderUserId: 'guest-1',
        text: 'See you at 19:00',
      }),
    );

    await assertFails(
      setDoc(doc(outsiderDb, 'chatThreads', 'thread-1', 'messages', 'message-2'), {
        threadId: 'thread-1',
        senderUserId: 'outsider-1',
        text: 'I should not be here',
      }),
    );
  },
);

test('denies invalid report reasons and invalid block ids', { skip }, async () => {
  const reporterDb = testEnv.authenticatedContext('reporter-1').firestore();
  const ownerDb = testEnv.authenticatedContext('owner-1').firestore();

  await assertSucceeds(setDoc(doc(reporterDb, 'reports', 'report-1'), reportFixture));

  await assertFails(
    setDoc(doc(reporterDb, 'reports', 'report-2'), {
      ...reportFixture,
      reason: 'freeform_reason',
    }),
  );

  await assertSucceeds(setDoc(doc(ownerDb, 'blocks', 'owner-1-guest-1'), blockFixture));

  await assertFails(setDoc(doc(ownerDb, 'blocks', 'guest-1-owner-1'), blockFixture));
});
