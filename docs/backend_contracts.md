# Backend Contracts

This document maps current repository abstractions to the Firebase collections they should use when in-memory implementations are replaced.

## Repository Map

- `AuthRepository`: Firebase Auth, with profile existence checks through `profiles`.
- `ProfileRepository`: `profiles/{userId}` for public profile data and completion state.
- `ActivityRepository`: `activities/{activityId}` for real-life plans.
- `JoinRequestRepository`: `activities/{activityId}/joinRequests/{requestId}` for activity-scoped requests.
- `ChatRepository`: `chatThreads/{threadId}` and `chatThreads/{threadId}/messages/{messageId}` for approved coordination chat.
- `SafetyRepository`: `reports/{reportId}` and `blocks/{blockId}` for user actions.
- `ModerationRepository`: `trustEvents/{eventId}` and `moderationEvents/{eventId}` for visible and internal safety records.
- `RemoteConfigService`: Firebase Remote Config keys defined in `lib/core/config/remote_config_keys.dart`.
- `AnalyticsService`: Firebase Analytics event names defined in `lib/core/utils/analytics_events.dart`.

## Repository Source

The active backend mode is selected through `AppConfig.repositorySource` and exposed to Riverpod through `repositorySourceProvider`. Keep it on `RepositorySource.inMemory` until Firebase-backed implementations are added for the repositories and services behind `lib/shared/providers/repository_factories.dart`.

For the short side-by-side reference, use `docs/repository_source_comparison.md`.

## Repository Behavior Matrix

| Seam | In-memory behavior | Firebase behavior |
| --- | --- | --- |
| `ActivityRepository.createPlan` | trims core text fields and no-ops invalid or duplicate ids | trims core text fields, no-ops invalid or duplicate ids, writes timestamps through Firestore |
| `JoinRequestRepository.submitJoinRequest` | trims payloads and no-ops duplicate active requests | trims payloads, requires signed-in user, keeps one request document per user/activity |
| `ChatRepository.sendMessage` | trims/clamps text and no-ops blanks or unknown thread ids | trims/clamps text, requires signed-in Firebase user, throws on missing auth |
| `SafetyRepository.reportUser` | normalizes target/reason and no-ops invalid inputs | normalizes target/reason and no-ops invalid inputs before Firestore write |
| `SafetyRepository.blockUser` | normalizes target id and no-ops invalid/self targets | normalizes target id and no-ops invalid/self targets before Firestore write |

## Error Strategy

- Prefer silent no-op for invalid local payloads that are recoverable at the UI level: blank text, duplicate active requests, self-targeted safety actions.
- Prefer typed or explicit throw when an authenticated backend dependency is truly required and missing, such as Firebase-backed chat send without a signed-in user.
- Keep repository normalization deterministic so UI state, tests, rules, and backend hooks all agree on what is valid.

## Timestamp Notes

- In-memory repositories emit plain Dart `DateTime` values.
- Firebase repositories normalize Firestore `Timestamp` objects into `DateTime` at the model-mapping boundary.
- New Firebase-backed seams should keep timestamp conversion inside repository adapters or model-map helpers, never in widgets.

## Field Naming

Use constants from `FirebaseDocumentFields` instead of writing Firestore field strings inside repositories. This keeps future Freezed/json models, Firestore converters, and security rules aligned.

## Enum Naming

Store enum values as their Dart `.name` strings. Read them through `lib/core/utils/enum_codecs.dart` so unknown or missing backend values fall back safely instead of crashing the UI.

## Model Maps

Use `lib/shared/models/model_maps.dart` as the first mapping boundary between repository documents and domain models. It intentionally avoids Firebase SDK imports, so Firestore repositories can adapt SDK-specific `Timestamp` and snapshot values before calling the pure Dart mappers.

## Path Naming

Use constants and helpers from `FirebaseCollectionPaths` for collection paths:

- Top-level collections such as `profiles`, `activities`, `chatThreads`, `reports`, and `blocks`
- Activity-scoped join requests through `activityJoinRequests(activityId)`
- Thread-scoped messages through `chatThreadMessages(threadId)`
- User-scoped notification tokens through `userNotificationTokens(userId)`

Expected query/index combinations for these paths are tracked in `docs/firestore_indexes.md`.

## Privacy Boundaries

- Activity documents may include approximate location, but not exact public live location by default.
- Direct client activity updates are intentionally narrow and currently only cover owner-side participant-count/status fallback metadata.
- Join request documents should be visible only to the requester and the activity owner.
- Chat thread and message documents should be visible only to approved participants.
- Chat thread creation is backend-owned after join approval; clients may only send messages as their authenticated user and update the thread preview metadata that mirrors their latest sent message.
- Reports and internal moderation events should not be publicly readable.
- Report writes should use a small canonical reason taxonomy so Cloud Functions and moderation tooling do not depend on arbitrary freeform strings.
- The safety UI should present controlled report-reason choices that map directly to the canonical moderation taxonomy.
- User-facing safety summaries may show counts, but should not expose public reporter-to-reported ledgers or reputation-style scorecards.
- Trust events can include user-visible safety timeline records, but internal risk signals should stay private.

## Safety UX Notes

- Blocked users should disappear consistently from explore, map, and chat coordination surfaces once the local trust-event stream reflects the block.
- If a blocked relationship hides a chat thread, the chat empty state should explain that the thread is intentionally hidden instead of implying data loss.
- Trusted contact and safe-return flows remain planned placeholder architecture only; when implemented they should stay private, opt-in, and operational rather than public-facing signals.
- Verification state should remain a private trust indicator with room for expansion, not a public humiliation mechanic.

## Cloud Functions Hooks

- On join request created: notify activity owner.
- On join request approved: create or reveal chat thread and notify requester.
- On report created: enqueue moderation review and optionally update internal trust events.
- On block created: hide relevant plans and chats for the blocking user.
- On message created: run lightweight moderation checks and notify other participants unless an active block exists between sender and recipient.

Detailed trigger responsibilities and side effects are tracked in `docs/functions_contracts.md`.
Cross-cutting block/report/trust behavior is tracked in `docs/safety_backend_contracts.md`.

## Migration Discipline

Use `docs/migration_checklist.md` when moving any repository or service to Firebase-backed implementations. The goal is to migrate one seam at a time while keeping `RepositorySource.inMemory` stable and reviewable.
