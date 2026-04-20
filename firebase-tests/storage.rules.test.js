const test = require('node:test');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const { getBytes, ref, uploadString } = require('firebase/storage');
const {
  emulatorSkipReason,
  hasEmulatorRuntime,
  readWorkspaceFile,
} = require('./helpers/runtime');

const runtimeReady = hasEmulatorRuntime();
const skip = runtimeReady ? false : emulatorSkipReason();
const projectId = 'nar-rehberi-storage-rules-tests';

let testEnv;

async function seedStorageObject(filePath, contentType = 'image/png') {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await uploadString(
      ref(context.storage(), filePath),
      'fixture-image',
      'raw',
      { contentType },
    );
  });
}

test.before(async () => {
  if (!runtimeReady) {
    return;
  }

  const storageRules = await readWorkspaceFile('storage.rules');
  testEnv = await initializeTestEnvironment({
    projectId,
    storage: {
      rules: storageRules,
      host: '127.0.0.1',
      port: 9199,
    },
  });
});

test.after(async () => {
  if (!runtimeReady || !testEnv) {
    return;
  }

  await testEnv.cleanup();
});

test('allows self profile photo uploads with supported image types', { skip }, async () => {
  const storage = testEnv.authenticatedContext('owner-1').storage();
  await assertSucceeds(
    uploadString(
      ref(storage, 'profilePhotos/owner-1/photo.png'),
      'image-content',
      'raw',
      { contentType: 'image/png' },
    ),
  );
});

test('allows signed-in profile photo reads', { skip }, async () => {
  await seedStorageObject('profilePhotos/owner-1/photo.png');
  const signedInStorage = testEnv.authenticatedContext('guest-1').storage();

  await assertSucceeds(getBytes(ref(signedInStorage, 'profilePhotos/owner-1/photo.png')));
});

test('denies cross-user or unsupported profile photo uploads', { skip }, async () => {
  const otherStorage = testEnv.authenticatedContext('guest-1').storage();

  await assertFails(
    uploadString(
      ref(otherStorage, 'profilePhotos/owner-1/photo.png'),
      'image-content',
      'raw',
      { contentType: 'image/png' },
    ),
  );

  await assertFails(
    uploadString(
      ref(otherStorage, 'profilePhotos/guest-1/document.txt'),
      'plain-text',
      'raw',
      { contentType: 'text/plain' },
    ),
  );
});

test('denies signed-out storage access', { skip }, async () => {
  await seedStorageObject('profilePhotos/owner-1/photo.png');

  const unauthenticatedStorage = testEnv.unauthenticatedContext().storage();
  await assertFails(
    uploadString(
      ref(unauthenticatedStorage, 'profilePhotos/owner-1/photo.png'),
      'image-content',
      'raw',
      { contentType: 'image/png' },
    ),
  );
  await assertFails(
    getBytes(ref(unauthenticatedStorage, 'profilePhotos/owner-1/photo.png')),
  );
});

test('allows verification uploads but denies reads', { skip }, async () => {
  const ownerStorage = testEnv.authenticatedContext('owner-1').storage();

  await assertSucceeds(
    uploadString(
      ref(ownerStorage, 'verification/owner-1/proof.webp'),
      'image-content',
      'raw',
      { contentType: 'image/webp' },
    ),
  );

  await seedStorageObject('verification/owner-1/private.png');

  await assertFails(getBytes(ref(ownerStorage, 'verification/owner-1/private.png')));
});

test('denies cross-user verification uploads', { skip }, async () => {
  const guestStorage = testEnv.authenticatedContext('guest-1').storage();

  await assertFails(
    uploadString(
      ref(guestStorage, 'verification/owner-1/proof.webp'),
      'image-content',
      'raw',
      { contentType: 'image/webp' },
    ),
  );
});
