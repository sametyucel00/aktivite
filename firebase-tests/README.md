# Firebase Emulator Test Scaffold

This folder is the starting point for fixture-oriented Firebase emulator tests.

Current intent:

- keep Firestore rules fixtures separate from Flutter unit tests
- make it easy to add emulator-backed tests once JDK 21 is available locally and in CI
- avoid mixing SDK-specific emulator setup into normal widget and model tests

Planned first layers:

1. Firestore rules fixtures for activity, join request, chat, report, and block documents
2. Rules tests that assert allow/deny behavior for authenticated actors
3. Storage rules tests for profile photo and verification paths

Available fixture seeds:

- `fixtures/activity.json`
- `fixtures/join_request.json`
- `fixtures/chat_thread.json`
- `fixtures/report.json`
- `fixtures/block.json`

This scaffold is present now, but emulator execution is still blocked locally until Java 21 is available for the current Firebase CLI.
