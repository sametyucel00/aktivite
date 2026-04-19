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
- Join request documents should be visible only to the requester and the activity owner.
- Chat thread and message documents should be visible only to approved participants.
- Chat thread creation is backend-owned after join approval; clients may only send messages as their authenticated user.
- Reports and internal moderation events should not be publicly readable.
- Trust events can include user-visible safety timeline records, but internal risk signals should stay private.

## Cloud Functions Hooks

- On join request created: notify activity owner.
- On join request approved: create or reveal chat thread and notify requester.
- On report created: enqueue moderation review and optionally update internal trust events.
- On block created: hide relevant plans and chats for the blocking user.
- On message created: run lightweight moderation checks and notify other participants unless an active block exists between sender and recipient.

Detailed trigger responsibilities and side effects are tracked in `docs/functions_contracts.md`.

## Migration Discipline

Use `docs/migration_checklist.md` when moving any repository or service to Firebase-backed implementations. The goal is to migrate one seam at a time while keeping `RepositorySource.inMemory` stable and reviewable.
