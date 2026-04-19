const fs = require('node:fs/promises');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const workspaceRoot = path.resolve(__dirname, '..', '..');

function workspacePath(...segments) {
  return path.join(workspaceRoot, ...segments);
}

async function readWorkspaceFile(...segments) {
  return fs.readFile(workspacePath(...segments), 'utf8');
}

async function readFixture(name) {
  const filePath = path.join(__dirname, '..', 'fixtures', `${name}.json`);
  const content = await fs.readFile(filePath, 'utf8');
  return JSON.parse(content);
}

function getJavaMajorVersion() {
  const result = spawnSync('java', ['-version'], { encoding: 'utf8' });
  if (result.error) {
    return null;
  }

  const output = `${result.stdout || ''}\n${result.stderr || ''}`;
  const match = output.match(/version "([^"]+)"/);
  if (!match) {
    return null;
  }

  const version = match[1];
  if (version.startsWith('1.')) {
    const legacyParts = version.split('.');
    return Number.parseInt(legacyParts[1], 10) || null;
  }

  return Number.parseInt(version.split('.')[0], 10) || null;
}

function hasEmulatorRuntime() {
  const javaMajorVersion = getJavaMajorVersion();
  return Boolean(
    javaMajorVersion >= 21 &&
    process.env.FIRESTORE_EMULATOR_HOST &&
    process.env.FIREBASE_STORAGE_EMULATOR_HOST,
  );
}

function emulatorSkipReason() {
  const javaMajorVersion = getJavaMajorVersion();
  if (!javaMajorVersion || javaMajorVersion < 21) {
    return 'JDK 21 or newer is required for the current Firebase CLI.';
  }

  if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_STORAGE_EMULATOR_HOST) {
    return 'Run the suite through firebase emulators:exec so emulator hosts are available.';
  }

  return '';
}

module.exports = {
  emulatorSkipReason,
  hasEmulatorRuntime,
  readFixture,
  readWorkspaceFile,
  workspacePath,
};
