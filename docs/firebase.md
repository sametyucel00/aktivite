# Firebase Setup

Togio uses Firebase behind repository and service interfaces. Local development can run against in-memory implementations until Firebase platform configuration is generated.

## Required Products

- Firebase Auth for identity and session state
- Cloud Firestore for profiles, activities, join requests, chats, reports, blocks, and trust events
- Firebase Storage for profile photos, verification media, and future report attachments
- Firebase Cloud Messaging for coordination notifications
- Firebase Analytics for funnel and retention events
- Firebase Crashlytics for runtime error reporting
- Firebase Remote Config for rollout controls and safety tuning
- Cloud Functions for join-request workflows, notification fanout, moderation hooks, and background trust updates

## Local Setup

1. Install the Firebase CLI and FlutterFire CLI.
2. Create or select the Firebase project for the environment.
3. Run `flutterfire configure` from the repository root.
4. Confirm `lib/firebase_options.dart` is generated locally.
5. Keep real secrets out of public review. Firebase client configuration files are tracked for CI because the app imports them at compile time; protect data with Firebase Auth, rules, App Check, and backend validation rather than by treating client API keys as secrets.
6. Set the visible app identity and native ids to the current product values:
   - Android package: `com.togio.app`
   - iOS bundle id: `com.togio.app`
7. Pass `GOOGLE_MAPS_API_KEY` through local build settings or CI secrets rather than hardcoding it into tracked files.
8. Run `.\tool\check.ps1` after configuration.
9. Use `docs/manual_qa_checklist.md` for focused smoke validation after larger flow changes.

Use `docs/migration_checklist.md` as the step-by-step playbook when replacing in-memory seams with Firebase-backed implementations.

## Repository Policy

- `lib/firebase_options.dart` and native Firebase client config files are tracked so GitHub Actions can analyze and build the app without a manual FlutterFire step.
- Do not commit service account JSON, private keys, `.env` files, local emulator exports, or production signing credentials.
- Current Android GitHub secret requirement: `GOOGLE_MAPS_API_KEY`
- Future Android release signing can be added later with separate keystore secrets; it is not required for the current debug-oriented CI flow.
- Widgets should not call Firebase SDKs directly.
- Feature code should depend on repository or service abstractions.
- Firestore collection and field names should use centralized constants from `lib/core/config`.
- Storage paths should use centralized helpers from `lib/core/config`.
- Repository-to-collection ownership is documented in `docs/backend_contracts.md`.
- Expected Firestore query/index shapes are tracked in `docs/firestore_indexes.md`.
- Cloud Functions workflow contracts are tracked in `docs/functions_contracts.md`.
- Cross-cutting trust-and-safety visibility rules are tracked in `docs/safety_backend_contracts.md`.
- Storage path verification scenarios are tracked in `docs/storage_rules_scenarios.md`.

## Initial Data Boundaries

- `users` and `profiles` store identity-adjacent public profile data separately from private auth state.
- `activities` stores real-life plans with approximate location data only.
- `joinRequests` stores approval workflow state before chat access.
- `chatThreads` and nested or related `messages` store coordination-focused chat.
- `moderationEvents`, `trustEvents`, `reports`, and `blocks` support safety workflows without public reputation scoring.
- `notificationTokens` stores device tokens scoped to the owning user.

## Security Notes

- Public discovery must not expose exact home or live location.
- Users should only edit their own profile, preferences, tokens, and owned plans.
- Join requests should only be readable by the requester and plan owner.
- Chat messages should only be readable by approved thread participants.
- Reports and internal moderation events should not be publicly readable.

## Source Selection Reminder

Keep `AppConfig.repositorySource` on `RepositorySource.inMemory` until the migrated dependency is implemented, tested, and documented. Do not switch the whole app to `RepositorySource.firebase` early just because one service is ready.
