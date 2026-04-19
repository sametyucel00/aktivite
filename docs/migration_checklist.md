# Firebase Migration Checklist

Use this checklist to keep the repository shippable while moving from `RepositorySource.inMemory` to Firebase-backed seams.

## 1. Environment

1. Install Flutter, Firebase CLI, and FlutterFire CLI on the Windows development machine.
2. Run `flutterfire configure`.
3. Confirm `lib/firebase_options.dart` exists locally.
4. Confirm platform folders exist for Android, Web, Windows, and iOS architecture support.
5. Run the local quality gate before touching repository source selection.

## 2. Bootstrap

1. Replace the no-op `AppBootstrapService.initialize()` with real Firebase initialization.
2. Keep bootstrap free of feature-specific business logic.
3. Confirm app startup still works when Firebase configuration is missing locally only if that fallback is intentionally preserved.
4. Document any new generated files or setup assumptions in `README.md`.

## 3. Per-Seam Migration

Move one dependency at a time:

1. Add Firebase-backed implementation.
2. Reuse centralized field/path constants.
3. Reuse enum codecs and pure model mappers.
4. Add focused tests for mapper and repository behavior.
5. Keep the in-memory implementation passing.
6. Keep `RepositorySource.inMemory` as the default until the migrated dependency is reviewable.

Suggested order:

1. `AuthRepository`
2. `ProfileRepository`
3. `ActivityRepository`
4. `JoinRequestRepository`
5. `ChatRepository`
6. `ModerationRepository`
7. `SafetyRepository`
8. `AnalyticsService`
9. `RemoteConfigService`

## 4. Feature Validation

After each repository/service migration, verify:

- auth/session startup
- onboarding/profile persistence
- activity publish/discover/update flows
- join request submission and owner approval
- chat hydration and send flow
- safety report/block flow
- settings and remote-config-driven gates

## 5. Rules And Backend

1. Update Firestore and Storage rules in line with `docs/security_rules.md`.
2. Add required Firestore indexes in line with `docs/firestore_indexes.md`.
3. Add or stub Cloud Functions in line with `docs/functions_contracts.md`.
4. Verify device token ownership and notification fanout assumptions.
5. Keep block/report/trust visibility behavior aligned with `docs/safety_backend_contracts.md`.

## 6. Source Flip Gate

`RepositorySource.firebase` should only be considered ready when:

- factory tests still pass for both in-memory and firebase-source failure expectations that remain intentionally unsupported
- provider wiring tests still pass
- migrated dependencies have focused tests
- `flutter analyze` passes
- `flutter test` passes
- app startup is verified with real Firebase config

## 7. Cleanup

1. Remove only the in-memory seams that are no longer needed.
2. Preserve test coverage around domain helpers and provider seams.
3. Update `README.md`, `docs/backend_contracts.md`, `docs/firebase.md`, and `docs/safety_backend_contracts.md`.
4. Keep review diffs scoped by dependency or workflow, not by broad rewrite.

## Current Ready Assets

- Firebase config is tracked through `lib/firebase_options.dart`
- Firestore index plan exists in `firestore.indexes.json` and `docs/firestore_indexes.md`
- initial Cloud Functions scaffold exists in `functions/index.js`
- pure Cloud Functions helper tests exist in `functions/index.test.js`
- emulator-focused Firestore rules scaffold exists in `firebase-tests/`
- widget/provider/model coverage already protects join, chat, safety, and blocked-visibility regressions before the source flip
- `.\tool\check.ps1` for the local scripted quality gate
- `docs/manual_qa_checklist.md` for manual smoke coverage
- `docs/storage_rules_scenarios.md` for future Storage emulator assertions
- `docs/safety_backend_contracts.md` for cross-surface safety alignment
- `docs/repository_source_comparison.md` for a short in-memory vs firebase seam comparison
