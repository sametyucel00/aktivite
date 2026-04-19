# Firebase Emulator Tests

This folder now contains the dedicated Node-based rules test layer for Firestore and Storage.

Goals:

- keep Firebase emulator assertions separate from Flutter unit and widget tests
- make rules coverage explicit, reviewable, and CI-friendly
- keep fixture-path mapping deterministic across docs, rules, and emulator tests

## Files

- `firestore.rules.test.js`: Firestore allow/deny assertions
- `storage.rules.test.js`: Storage allow/deny assertions
- `helpers/runtime.js`: fixture loading and local runtime checks
- `fixtures/`: deterministic JSON seeds used by the rules suite

## Available fixture seeds

- `fixtures/activity.json`
- `fixtures/join_request.json`
- `fixtures/chat_thread.json`
- `fixtures/report.json`
- `fixtures/block.json`
- `fixtures/manifest.json`

## Fixture-to-path mapping

- `activities/activity-1`
- `activities/activity-1/joinRequests/guest-1`
- `chatThreads/thread-1`
- `reports/report-1`
- `blocks/owner-1-guest-1`

The same mapping is also stored in `fixtures/manifest.json` so future emulator setup can load fixture-path pairs programmatically.

## Commands

Install test dependencies:

```powershell
npm --prefix firebase-tests install
```

Static syntax check without emulator runtime:

```powershell
npm --prefix firebase-tests run test:static
```

Run the emulator-backed rules suite:

```powershell
npm --prefix firebase-tests test
```

## Runtime requirement

- Firebase CLI `15.11.0` currently needs JDK 21 or newer for emulator execution.
- If local Java is older, use `test:static` first and let CI run the full emulator-backed suite.

Use `docs/rules_checklist.md` as the source of truth for which rule boundaries already have named emulator placeholders and which ones still need scaffold coverage.
These tests should stay aligned with `firestore.rules`, `storage.rules`, `docs/security_rules.md`, and `docs/firestore_indexes.md`.
