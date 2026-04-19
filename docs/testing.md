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
7. manual QA using `docs/manual_qa_checklist.md` for higher-risk changes

## Current Test Layers

- Pure Dart utility tests for enum parsing, profile completion, trust-event helpers, join-plan status, and remote config logic
- Model tests for profile, chat, join request, and serialization helpers
- In-memory repository/service tests for auth, profile, activities, join requests, chat, moderation, analytics, remote config, and safety bookkeeping
- Provider seam tests for app-level derived state plus repository/provider source selection
- Widget tests for safety, chat, join CTA, and owner request ordering regressions
- Node unit tests for pure Cloud Functions helper logic in `functions/helpers/`
- Firebase emulator tests in `firebase-tests/` for Firestore and Storage rules

## Manual Verification Priorities

For manual checks, use `docs/manual_qa_checklist.md`, with extra attention to:

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
6. verify the change still matches `docs/security_rules.md`, `docs/firestore_indexes.md`, and `docs/safety_backend_contracts.md`
7. verify any changed rule boundary still matches `docs/rules_checklist.md`

Firebase emulator-based rule checks require JDK 21 or newer with the current Firebase CLI.

## Emulator Tests

- `firebase-tests/` contains the dedicated Node-based emulator suite.
- `firebase-tests/fixtures/` stores minimal JSON fixtures for activity, join request, chat, report, and block cases so rules tests stay deterministic.
- `npm --prefix firebase-tests run test:static` validates syntax without emulator runtime.
- `npm --prefix firebase-tests test` runs the Firestore and Storage rules suite through `firebase emulators:exec`.
- storage-rule scenarios are documented separately in `docs/storage_rules_scenarios.md`
- `docs/rules_checklist.md` tracks which rule boundaries are already implemented vs still waiting on emulator assertions
- Full emulator execution still requires JDK 21 or newer with the current Firebase CLI.

## CI Expectation

GitHub Actions should continue to cover:

- functions lint and helper tests
- firebase emulator-backed Firestore and Storage rules tests
- format verification
- static analysis
- tests
- web build
- Android debug build

Windows build can remain a local-first verification step until CI capacity requires it.
