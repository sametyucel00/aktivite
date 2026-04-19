# Safety Backend Contract

This document collects the cross-cutting trust-and-safety behavior that spans Firestore rules, Cloud Functions, repositories, and user-facing coordination surfaces.

## Scope

Use this as the single contract for:

- block effects across discovery, chat, and notifications
- report taxonomy and moderation hooks
- trusted-contact and safe-return placeholders
- verification visibility boundaries
- future abuse and rate-limit hooks

## Block Contract

An active block is an operational safety action, not a public social signal.

Current repository and backend expectations:

- blocked owners should disappear from discovery-facing surfaces such as explore and map
- blocked chat threads should disappear from the coordination inbox for the blocking user
- blocked chat removal should be explained with a safety-first empty state instead of implying data loss
- notification fanout must be suppressed when either side has an active block against the other
- block records should stay private to the blocking user and backend tooling

Product boundary for MVP:

- existing threads are hidden rather than shown with a confrontational public warning
- block state must not create public badges, reputation penalties, or visible scorecards

## Report Contract

Reports use a controlled canonical reason taxonomy:

- `spam`
- `harassment`
- `unsafe_meetup`
- `fake_profile`
- `inappropriate_content`

Expected flow:

1. UI presents controlled reason choices
2. repository normalizes the selected reason
3. Firestore rules validate the canonical reason set
4. Cloud Functions re-validate and emit internal moderation events with canonical `report_<reason>` codes

Reports remain private:

- users may see lightweight self-service summary counts
- users should not see public ledgers of who reported whom
- reports must not become a public rating mechanic

## Verification Contract

Verification is a private trust indicator with limited user-facing exposure.

Rules:

- the app may show coarse verification level such as phone-verified
- raw verification evidence stays private
- verification should help safety posture, not publicly shame users with failure states
- future expansion should prefer incremental trust signals over binary "good/bad user" messaging

## Trusted Contact Placeholder

Trusted contact remains contract-only for the MVP and should not get a user-facing flow in this phase.

Future boundary when implemented:

- it should be explicit opt-in
- contact data should be private to the user and backend workflow
- the feature should support operational reminders or escalation, not public profile decoration
- no trusted-contact state should leak into discovery cards or profile reputation surfaces

## Safe Return Placeholder

Safe return also remains contract-only for the MVP.

Future boundary when implemented:

- keep the first version minimal: check-in state, due time, optional note
- prefer operational reminders and internal safety handling over social visibility
- avoid turning safe-return state into a public "last seen safe" feed
- do not add dashboard, profile, or public recap UI for safe-return state in the MVP

## Abuse And Rate-Limit Hooks

Future backend hooks may add internal enforcement for:

- repeated report spam
- repeated join-request spam
- repeated notification-token churn
- suspicious burst messaging

These hooks should:

- stay internal to moderation or operational workflows
- create private moderation signals rather than user-visible penalties by default
- avoid storing unnecessary message content when metadata is enough

For MVP, keep these hooks contract-level only; do not surface them as explicit UI warnings or public enforcement counters.

## Finalized MVP Decisions

- blocked threads stay hidden rather than rendering a dedicated safety-hidden thread row
- verification remains coarse and low-visibility; do not add detailed failure states or public history
- approximate location remains the only discovery-facing location signal; exact coordinates stay out of scope
- activity update flows remain out of MVP scope
- join summary data stays local to activity and safety surfaces, not dashboard or settings
- deeper blocked or reported history views stay out of MVP scope

## Source Of Truth Split

- `docs/security_rules.md`: client and rule boundaries
- `docs/functions_contracts.md`: trigger responsibilities and side effects
- `docs/backend_contracts.md`: repository seam behavior and data ownership
- this document: cross-cutting safety behavior that must stay aligned across all three
