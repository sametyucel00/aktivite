# Aktivite Architecture

## Product And Engineering Summary

Aktivite is a real-life social activity app for low-pressure companionship and simple plans. The product centers on practical in-person activities such as coffee, walking, coworking, events, movies, games, and short spontaneous meetups. The architecture is optimized for trust, clarity, and fast coordination rather than vanity metrics, swiping, or romance-first mechanics.

The repository is designed for Windows-first development while keeping Android, Web, Windows, and iOS support in the product architecture. Firebase is the backend platform, but platform-specific runtime setup is isolated so local development stays clean and predictable.

## Core Architecture Goals

- Feature-first modular structure
- Riverpod-driven dependency boundaries
- `go_router` app shell with clear navigation
- Firebase concerns isolated behind repositories and services
- Localization-ready UI from day one
- Safety and privacy hooks built into the domain model
- Reviewable, CI-friendly repository layout for GitHub-first workflows

## Folder Structure

```text
lib/
  app/
    app.dart
    router.dart
    config/
    theme/
  core/
    constants/
    enums/
    services/
    utils/
  shared/
    design_system/
    models/
    providers/
    widgets/
  features/
    activities/
    auth/
    chat/
    explore/
    map/
    onboarding/
    profile/
    safety/
    settings/
```

## State And Dependency Strategy

- Riverpod providers define app-wide dependencies and feature access points.
- Firebase-facing features depend on repository abstractions rather than direct widget access.
- Firebase collection and storage paths are centralized under `core/config` before concrete SDK repositories are introduced.
- Repository-to-collection contracts are documented so Firestore implementations can be added without changing widgets.
- Enum serialization helpers keep Firestore string values aligned with Dart enum names and provide safe fallbacks for stale backend data.
- Pure Dart model map helpers keep domain serialization testable before Firebase SDK repositories are introduced.
- Pure helper tests cover enum codecs and model map round-trips before and during Firebase-backed repository rollout.
- Repository and service providers now read a single backend source so in-memory and Firebase implementations can share the same Riverpod wiring.
- The first Firebase-backed repository waves now cover auth session state, current-profile persistence, activity plan read/write flows, join-request persistence, participant-scoped chat streams, and trust-event moderation streams without changing feature-level provider contracts.
- Session state now derives from the auth repository stream, which keeps router auth gating aligned with future Firebase Auth synchronization.
- Auth entry now uses a dedicated phone-form controller so validation, normalization, and unsupported verification errors stay out of the widget tree before OTP callbacks are introduced.
- Phone auth now flows through a typed repository result so Android/iOS code-sent callbacks can coexist with demo sign-in and unsupported desktop/web fallbacks without widget-level exception parsing.
- Phone auth verification now has a second repository-driven confirmation step so SMS code entry, submit state, and failure mapping stay centralized in the auth form controller.
- Profile media now flows through dedicated picker and storage services so onboarding/profile UI can preview selected photos immediately while persistence stays backend-aware.
- Profile media upload is guarded by a shared policy for supported image types, sanitized file names, and a 5 MB upload limit before data reaches Firebase Storage.
- Activity composition now stores concrete schedule and duration metadata alongside privacy-first approximate location text, keeping discovery labels separate from persisted planning data.
- Activity composition validation is centralized so screens, tests, and repositories share the same expectations for approximate location, schedule, and supported duration values.
- Profile completion scoring is centralized in a pure utility so onboarding, profile editing, and creation gates use the same rule set.
- UI gating for plan creation now derives from shared profile capability state instead of repeating raw threshold checks in screens.
- Preference-driven safety and privacy decisions are moving behind small model/helper boundaries instead of living entirely inside settings widgets.
- Coordination models now expose lightweight helpers so chat repositories and widgets share the same banner, participant, and message-trimming rules.
- Map privacy rollout and preference overrides now converge on a typed mode so remote config parsing and UI rendering share the same contract.
- Shared design system and domain models stay UI-framework friendly and reusable across screens.
- Router composition and shell navigation remain in `app/` so features stay focused on domain behavior.
- The current scaffold uses in-memory repositories and a session controller so auth, onboarding, and navigation can be exercised before Firebase runtime setup is available.
- Remote-config-shaped providers already influence safety banners, active plan limits, and public map privacy behavior to keep rollout hooks explicit.
- Analytics service wiring now supports a Firebase-backed implementation while keeping an inspectable local event stream for testable product signals.
- Ownership-aware providers separate public discovery plans from the current user's managed plans so owner workflows and nearby browsing do not leak into each other.
- Shell badges derive from provider state to surface pending approvals and active coordination threads without adding feed-like noise.
- Join-request status lookup and localized status copy are shared so explore and map remain behaviorally consistent.
- Aggregated owner request providers summarize demand across managed plans without pushing repository details into presentation widgets.
- Shared localized label utilities centralize enum-to-copy rendering so onboarding, profile, and plan creation stay terminology-consistent.
- Safety summary providers derive actionable moderation state for the signed-in user, allowing presentation widgets to disable duplicate trust actions without directly parsing event codes.
- Shared event-formatting utilities keep analytics signals and trust timeline entries readable without duplicating event-name parsing in screens.
- Settings now bridge preference state to visible trust records for safe meetup reminders, while guarding against duplicate trust events in local state.
- Trust events now carry creation timestamps so timeline UIs can show when a safety-relevant action happened instead of only what happened.
- Lightweight analytics summary providers roll recent events into auth, safety, and coordination buckets to keep settings informative without turning it into a feed.
- Shared route CTA widgets keep empty-state navigation and quick links consistent across feature surfaces.
- Shared trust signal widgets keep safety/privacy explanations aligned between explore and the safety center.
- Shared profile-gate widgets keep completion requirements consistent before discovery joins and plan creation.
- Shared feedback helpers surface local success states, such as plan publishing, without duplicating snackbar setup in screens.
- Firestore join-request, participant-count, report, and block writes include workflow metadata so Cloud Functions can distinguish server-side side effects from client fallback writes during migration.
- Shared join-plan action widgets centralize request status, profile gating, join dialogs, analytics, and success feedback across discovery surfaces.
- Trust event factories and reason-code constants keep safety records consistent across settings, safety actions, providers, and formatting utilities.
- Analytics event constants keep logging, readable signal formatting, and summary bucketing in sync across feature modules.
- Remote Config key/default helpers keep rollout-controlled values typed and centralized across both in-memory and Firebase-backed service implementations.
- App route constants keep router setup, shell tabs, and cross-feature quick actions aligned without repeating path strings.
- Sample identity constants keep in-memory auth, profiles, activities, join requests, chats, and moderation seeds aligned until Firebase ids replace them.
- Runtime clock and id helpers keep local generated records consistent until server-generated Firestore ids and timestamps replace them.
- Typed plan-time options keep activity creation logic independent from localized labels while still rendering localized copy in the UI.
- Activity plans keep typed time options where possible, while preserving localized/freeform labels as display and legacy fallback data for recommendation matching.
- Activity plan copy/update helpers and capacity/discovery getters keep repeated business rules out of repositories and widgets.

## Firebase Integration Plan

- Auth: identity and session state
- Firestore: profiles, activities, join requests, chats, trust events, moderation records
- Storage: profile images and future verification media
- Functions: join-request workflows, notifications, moderation hooks, trust updates
- FCM: time-sensitive coordination notifications
- Crashlytics: client error reporting
- Analytics: funnel, discovery, and retention measurement
- Remote Config: feature rollouts and tuning

## Safety And Privacy Decisions

- Public discovery uses approximate locations only
- Internal trust events are stored separately from public profile presentation
- Report, block, and moderation hooks exist at the domain boundary from day one
- Group size, activity context, and approval workflows reduce pressure and ambiguity
- Public humiliation mechanics such as star ratings are intentionally avoided
- The current MVP scaffold exposes a user-facing trust timeline while keeping room for internal-only moderation events

## Localization Plan

- ARB-based English and Turkish localization
- All user-facing strings go through generated localization delegates
- Shared terminology should remain practical and consistent across both languages
- Copy is written to reinforce a warm, trustworthy, activity-first tone

## Screen Inventory

- Auth welcome and session gate
- Onboarding overview
- Explore discovery hub
- Activity creation and activity detail placeholders
- Chat inbox and coordination thread placeholders
- Map discovery surface
- Safety center
- Profile overview
- Settings

## Testing Strategy

- Static analysis on every PR
- Local Windows verification through `tool/check.ps1`
- Format verification before analysis and tests
- Widget tests for app shell, discovery, and key reusable components
- Repository unit tests as Firebase-backed repositories are implemented
- Join-request model tests for owner approval and summary logic before Firestore migration
- Shared join-plan utility tests cover status labeling and submit eligibility outside widget code
- Join-request composer tests cover preset generation, normalization, and default-message detection outside dialog widgets
- In-memory join-request repository tests cover initial stream snapshots plus submit/update behavior before Firestore migration
- In-memory activity repository tests cover initial plan snapshots plus create/capacity status transitions before Firestore migration
- In-memory chat repository tests cover initial thread/message snapshots plus thread creation and message append behavior before Firestore migration
- In-memory moderation repository tests cover initial trust-event snapshots plus append/filter behavior before Firestore migration
- In-memory analytics service tests cover initial event snapshots plus newest-first event ordering before Firebase Analytics integration
- Remote Config tests cover default values plus fallback parsing for typed product gates before Firebase Remote Config integration
- In-memory safety repository tests cover normalized local block/report bookkeeping before those actions are fully connected to moderation persistence
- Repository factory tests cover every local dependency plus the currently implemented Firebase-backed seams
- Repository provider tests cover container-level source overrides so app wiring stays aligned with the factory seam
- Build checks for Web and Windows during active development
- Android debug build validation for device and emulator testing

Supporting operational docs live in `docs/testing.md` and `docs/security_rules.md` so Firebase migration work stays reviewable and aligned with the app boundary rules.
Use `docs/migration_checklist.md` as the dependency-by-dependency rollout guide before switching app-level backend source selection.
Use `docs/firestore_indexes.md` as the initial query/index planning note before Firestore-backed repositories add composite query shapes.
Use `docs/functions_contracts.md` as the trigger/side-effect planning note before approval, notification, and moderation flows move to Cloud Functions.

## Next Backend Implementation Steps

1. Add Freezed/json models for persisted entities and request payloads.
2. Replace the in-memory sample providers feature-by-feature as Firebase repositories become verified.
3. Wire the phone-auth verification UI on top of the Firebase Auth session repository.
4. Add profile media upload and approximate-location activity creation flows.
5. Add moderation workflows and Cloud Functions contracts.
