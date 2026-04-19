# Cloud Functions Contracts

This document describes the first backend workflows that should move to trusted server-side execution when Firebase-backed repositories are introduced. The first deployable scaffold lives in `functions/index.js`.

## Design Goals

- keep client widgets free of privileged backend orchestration
- protect approval and moderation side effects from client tampering
- centralize notification fanout and trust-event creation
- keep workflows low-pressure, safety-aware, and activity-first

## Join Request Created

Trigger:

- new document in `activities/{activityId}/joinRequests/{requestId}`

Function responsibilities:

- validate the referenced activity still exists
- validate the requester is not the owner
- notify the activity owner
- suppress owner notification if either side has an active block against the other
- optionally create an internal moderation signal if the requester is blocked or rate-limited

Outputs:

- owner notification fanout
- optional internal trust/moderation event
- invalid self-join requests are cancelled with workflow metadata

## Join Request Approved

Trigger:

- join request status changes from `pending` to `approved`

Function responsibilities:

- verify the actor is allowed to approve
- create or reveal the related chat thread
- ensure participants are limited to owner + approved requester for the MVP path
- stop side effects when the activity is full, cancelled, completed, or the requester is the owner
- notify the requester
- suppress requester notification if either side has an active block against the other
- optionally append a user-visible trust event if that product decision is kept

Outputs:

- chat thread creation or reveal
- requester notification
- optional trust event
- participant count update through a Firestore transaction
- workflow completion metadata on the join request
- capacity-blocked workflow metadata when approval cannot safely create coordination access
- idempotency guard so repeated trigger delivery does not increment participant count or fan out notifications twice

## Join Request Rejected

Trigger:

- join request status changes from `pending` to `rejected`

Function responsibilities:

- notify the requester if the product keeps that feedback loop
- suppress requester notification if either side has an active block against the other
- avoid creating chat access

Outputs:

- optional requester notification only

## Report Created

Trigger:

- new document in `reports/{reportId}`

Function responsibilities:

- validate minimum required report fields
- validate the report reason against the supported moderation taxonomy
- assume the client selected the reason from the controlled safety-reason UI and still re-validate server-side
- enqueue moderation review
- append internal moderation event
- optionally update internal trust risk state for the reported user

Outputs:

- moderation queue record
- internal moderation/trust updates with canonical `report_<reason>` codes

## Block Created

Trigger:

- new document in `blocks/{blockId}`

Function responsibilities:

- hide or exclude relevant plans, chats, and coordination visibility for the blocking user
- prevent future notification fanout between blocked pairs where practical
- leave room for future trusted-contact and safe-return hooks without turning block data into a public signal

Outputs:

- blocked-pair visibility updates
- optional cleanup or fanout suppression records

## Message Created

Trigger:

- new document in `chatThreads/{threadId}/messages/{messageId}`

Function responsibilities:

- verify sender still belongs to the thread
- fan out notifications to other participants
- suppress message notification fanout across active blocked pairs
- run lightweight moderation heuristics or enqueue async checks

Outputs:

- participant notifications
- optional moderation review signal
- invalid sender marker if the message sender is no longer a participant

## Notification Token Updated

Trigger:

- create/update/delete in `users/{userId}/notificationTokens/{tokenId}`

Function responsibilities:

- keep token records normalized
- remove obviously stale or malformed tokens if the backend policy allows it

Outputs:

- cleaned token registry for fanout workflows
- empty tokens are deleted and token metadata is normalized on write

## Operational Rules

- Prefer idempotent handlers; repeated deliveries must not create duplicate chat threads or duplicate trust events.
- Keep function writes scoped and explicit; do not let one trigger rewrite unrelated user data.
- Log enough structured context for debugging, but avoid storing sensitive freeform content when not needed.
- Route privileged writes through Cloud Functions instead of trusting client devices for approval or moderation side effects.
- Keep future abuse and rate-limit hooks private and operational; they should influence moderation workflows without becoming user-facing scorecards.

## Migration Notes

1. Implement one workflow at a time.
2. Keep the related repository/service seam testable in `RepositorySource.inMemory`.
3. Update `docs/backend_contracts.md`, `docs/security_rules.md`, `docs/safety_backend_contracts.md`, and `docs/migration_checklist.md` when a contract changes.
