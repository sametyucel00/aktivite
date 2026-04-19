# Aktivite

Aktivite is a Flutter + Firebase social activity app focused on helping people make simple real-life plans together such as coffee, walking, coworking, chatting, games, events, and casual group activities.

## Product Direction

- Activity-first, not romance-first
- Nearby and time-based discovery
- Safety and privacy before growth tricks
- Fast coordination over endless browsing
- Turkish and English from day one

## Tech Stack

- Flutter with null safety
- Riverpod for state management
- `go_router` for navigation
- Firebase Auth, Firestore, Storage, Functions, FCM, Crashlytics, Analytics, Remote Config
- Google Maps and location tooling
- ARB-based localization

## Local Setup

1. Install Flutter on Windows and enable Android, Web, and Windows desktop support.
2. Run `flutter pub get`.
3. Run `flutterfire configure` again only when Firebase app configuration changes.
4. Run `flutter gen-l10n`.
5. Run `dart run build_runner build --delete-conflicting-outputs` when Freezed/json models are added.
6. Use `.\tool\check.ps1` locally, and include `-BuildWeb`, `-BuildWindows`, or `-BuildAndroid` when those platform toolchains are available.

If the platform folders are still missing because the repository was bootstrapped before Flutter was installed locally, run `tool/bootstrap_windows.ps1` or `flutter create --platforms=android,ios,web,windows .` once before your first build.

## Verification

Use the Windows-first check script for the normal local quality gate:

```powershell
.\tool\check.ps1
```

Optional build checks can be enabled when the relevant platform toolchains are installed:

```powershell
.\tool\check.ps1 -BuildWeb -BuildWindows -BuildAndroid
```

The script runs dependency restore, localization generation, format verification, static analysis, and tests before any optional builds.

## Documentation

- [Architecture](docs/architecture.md)
- [Firebase setup](docs/firebase.md)
- [Backend contracts](docs/backend_contracts.md)
- [Security rules draft](docs/security_rules.md)
- [Testing guide](docs/testing.md)
- [Migration checklist](docs/migration_checklist.md)
- [Firestore index plan](docs/firestore_indexes.md)
- [Cloud Functions contracts](docs/functions_contracts.md)
- [Firestore rules](firestore.rules)
- [Storage rules](storage.rules)
- [Firestore indexes](firestore.indexes.json)

## GitHub-First Repo Policy

- Firebase client config is tracked because the app imports it during analysis and build.
- Do not commit service accounts, private keys, signing credentials, local emulator exports, or `.env` files.
- Keep changes small enough for review and run `.\tool\check.ps1` or the equivalent Flutter commands before opening a PR.
- Install JDK 21 or newer before running Firebase emulator-based rule checks.

## Current Repository State

This repository contains the initial production-oriented scaffold:

- feature-first architecture
- design system tokens and shared widgets
- localized app shell
- provider-backed app session and guarded route flow
- in-memory repository implementations that mirror future Firebase boundaries
- trust timeline, join-request coordination, and privacy-first map scaffolding
- in-memory analytics signals for discovery, onboarding, safety, chat, and settings actions
- shared join-request dialog flow across explore and map with practical note presets
- shared recommendation reason chips across explore and map surfaces
- lightweight plan-capacity, approval, and coordination chat scaffolding
- owner-facing activities flow now derives from user-owned plans instead of generic discovery lists
- bottom navigation badges surface pending join requests and active coordination threads
- shared join-request status helpers now keep explore and map labels aligned
- owner-side request summaries are aggregated across managed plans
- shared localized label utilities now reduce duplicate enum-to-copy mapping across onboarding, profile, and plan creation
- safety center now exposes action summaries and prevents duplicate report/block actions in the local state flow
- settings now render human-readable product signals and a quick preference summary
- enabling safe meetup reminders from settings now creates a trust event once for the signed-in user
- trust records now carry timestamps so safety history reads more like a real moderation timeline
- settings include a recent analytics summary and profile includes quick links to safety and settings
- route-based CTAs are shared so empty states and quick actions navigate consistently
- trust signal rendering is shared between explore and safety surfaces
- profile-completion gates now reuse one shared card across plan creation and discovery
- plan publishing uses the shared feedback helper so creation success is visible immediately
- join-request status and submission actions are shared between explore and map surfaces
- trust-event reason codes and timestamped event creation are centralized through a small factory utility
- analytics event names are centralized so logging, formatting, and signal summaries stay aligned
- Remote Config keys and fallback values are centralized so rollout defaults stay consistent
- route paths are centralized through `AppRoutes` so navigation and quick actions stay aligned
- in-memory seed user, activity, and thread ids are centralized through `SampleIds`
- runtime timestamp and generated id helpers are centralized through `AppClock` and `AppIdFactory`
- activity composer time selection uses typed `PlanTimeOption` values instead of localized string comparisons
- activity plans can carry typed time options so recommendation matching can avoid localized label parsing when available
- activity plan copy/update and capacity/discovery rules are centralized on the model to reduce duplicated business checks
- MVP screen inventory for auth, onboarding, explore, activities, chat, map, safety, profile, and settings

## Notes

- Firebase runtime initialization is intentionally deferred until `flutterfire configure` has been run in this environment.
- Firebase collection and storage path constants live under `lib/core/config` so backend implementations do not duplicate path strings.
- Backend repository-to-collection contracts are documented before concrete Firebase repositories are introduced.
- Firestore-ready enum codecs centralize enum string storage and safe fallback parsing.
- Pure Dart model map helpers define the first Firestore-ready serialization boundary without importing Firebase SDKs.
- Pure Dart enum and model-map helpers now have dedicated unit test coverage in `test/core` and `test/shared`.
- Repository/service selection now flows through a central backend-source seam so Firebase implementations can be swapped in without rewriting provider wiring.
- Session state now listens to the auth repository stream, so Firebase Auth can replace the demo backend without rewiring screens.
- Profile completion rules are now centralized so onboarding, profile editing, and plan gating stay aligned before Firestore persistence is added.
- Profile gates now read the shared profile capability instead of repeating numeric completion thresholds in UI code.
- Settings preference effects now read small domain helpers so privacy and reminder decisions are less tied to raw booleans in widgets.
- Chat thread and message models now carry small helper methods so coordination UI and repositories repeat less thread logic.
- Map privacy now uses a typed mode through remote config and providers instead of relying on raw string comparisons in UI code.
- Join request models now expose shared status helpers and summary aggregation so owner approval flows do not duplicate status logic across providers and screens.
- Join-plan status labels and submit gating now flow through one shared utility so map and explore surfaces stay aligned.
- Join-request compose presets, default-message detection, and blank-submit validation now flow through one controller boundary.
- In-memory join-request streams now emit an initial snapshot immediately so owner and plan surfaces do not wait for a mutation to show current request state.
- In-memory activity streams now also emit an initial snapshot immediately so discovery and owned-plan surfaces have current plans before any mutation happens.
- In-memory chat repositories now emit initial thread and message snapshots immediately so coordination screens do not wait for the first mutation to hydrate.
- In-memory moderation streams now emit an initial trust-event snapshot immediately so safety summaries and timelines can render current state without waiting for a new event.
- In-memory analytics streams now emit an initial snapshot immediately so signal summaries and event feeds have deterministic startup state.
- Remote Config defaults and fallback parsing are now covered with dedicated tests for map privacy, active plan limits, and safety-banner toggles.
- In-memory safety actions now keep normalized local block/report snapshots so safety flows are testable before moderation wiring is fully connected.
- Factory tests now cover every in-memory dependency, plus a Firebase-backed seam for auth, profile, activity, join-request, chat, moderation, safety, analytics, and remote config.
- Provider wiring tests now verify that repository source overrides produce the expected in-memory dependencies and Firebase-backed auth/profile/activity/join-request/chat/moderation/safety/analytics/remote-config providers.
- FlutterFire configuration for the `nar-rehberi` project now generates runtime Firebase options and Android service configuration for this workspace.
- Security-rule priorities and local testing playbooks are now documented for the Firebase migration phase.
- A repository-by-repository Firebase migration checklist is now documented so `RepositorySource` flips stay deliberate and reviewable.
- A Firestore index draft is now documented so discovery, join-request, chat, and safety queries can migrate without hidden backend surprises.
- Cloud Functions trigger contracts are now documented so approval, notification, and moderation side effects can move server-side deliberately.
- Auth now collects a real phone number with local validation and submit-state handling before the platform-specific OTP verification UI is fully connected.
- Auth repositories now return typed phone-verification results so immediate sign-in, code-sent, unsupported-platform, and failure states can share one contract.
- Auth now includes a second-step SMS code confirmation flow with typed failure mapping for invalid, expired, or rate-limited verification attempts.
- Auth SMS verification now exposes a resend action while preserving typed pending-verification state.
- Profile and onboarding flows now share a picker/storage-based photo upload seam so profile media can move to Firebase Storage without leaking SDK code into widgets.
- Profile media now has a shared file policy for supported image types, sanitized names, and a 5 MB safety limit before uploads reach Storage.
- Profile and onboarding photo flows now expose typed validation feedback and a remove-photo action before saving.
- Activity creation now carries typed schedule, duration, and approximate-location metadata instead of relying only on a loose time label and city string.
- Activity creation validation now checks approximate location, supported duration values, and clearly past schedule times through a shared helper.
- Firestore join approval and safety writes now include workflow metadata so future Cloud Functions and security rules can identify client fallback side effects.
- Cloud Functions now include notification fanout helpers for join-request and chat workflows, plus basic notification-token normalization.
- The current code is structured to stay reviewable and CI-friendly on GitHub from day one.
