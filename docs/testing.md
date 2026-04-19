# Testing Guide

This repository is designed for Windows-first daily development while keeping Android, Web, Windows, and future iOS support in mind.

## Local Quality Gate

Run the standard local check first:

```powershell
.\tool\check.ps1
```

Optional builds:

```powershell
.\tool\check.ps1 -BuildWeb -BuildWindows -BuildAndroid
```

## Expected Order

1. `flutter pub get`
2. `flutter gen-l10n`
3. format verification
4. `flutter analyze`
5. `flutter test`
6. optional platform builds

## Current Test Layers

- Pure Dart utility tests for enum parsing, profile completion, trust-event helpers, join-plan status, and remote config logic
- Model tests for profile, chat, join request, and serialization helpers
- In-memory repository/service tests for auth, profile, activities, join requests, chat, moderation, analytics, remote config, and safety bookkeeping
- Provider seam tests for app-level derived state plus repository/provider source selection
- Widget tests for safety, chat, join CTA, and owner request ordering regressions
- Node unit tests for pure Cloud Functions helper logic in `functions/helpers.js`

## Manual Verification Priorities

When Flutter SDK is available, verify:

- auth gate and onboarding flow
- activity create/join/approve path
- chat thread hydration and sending
- map privacy labels and fallback states
- safety timeline and block/report actions
- settings-driven analytics and trust-event side effects

## Firebase Migration Checks

After any Firebase-backed repository is introduced:

1. confirm factory + provider seam still passes for `RepositorySource.inMemory`
2. add focused tests for new mapper/repository behavior
3. verify collection/path constants are used
4. verify no widget imports Firebase SDK directly
5. document any new generated files or CLI steps

Firebase emulator-based rule checks require JDK 21 or newer with the current Firebase CLI.

## Emulator Scaffold

- `firebase-tests/` contains the initial fixture-oriented scaffold for future Firestore rules tests.
- `firebase-tests/fixtures/` stores minimal JSON fixtures for activity, join request, chat, report, and block cases so emulator tests can stay deterministic.
- The scaffold is intentionally lightweight until JDK 21 is available locally and the emulator job is wired into CI.

## CI Expectation

GitHub Actions should continue to cover:

- format verification
- static analysis
- tests
- web build
- Android debug build

Windows build can remain a local-first verification step until CI capacity requires it.
