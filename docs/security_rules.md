# Security Rules Draft

This document captures the minimum Firestore and Storage rule boundaries that should exist before the in-memory repositories are replaced. The first concrete rules live in `firestore.rules` and `storage.rules`.

## Firestore Collections

### `profiles/{userId}`

- Read: authenticated users can read public profile fields.
- Write: only `request.auth.uid == userId`.
- Private-only profile fields should move to a separate private document if they are added later.

### `activities/{activityId}`

- Read: authenticated users can read discoverable activity documents.
- Create: only authenticated users, with `ownerUserId == request.auth.uid`, `id == activityId`, non-empty core text fields, and no exact public location fields.
- Update/Delete: only the owner.
- Exact live location fields must not be publicly readable.

### `activities/{activityId}/joinRequests/{requestId}`

- Read: only the activity owner and the requester.
- Create: only authenticated requester, with `requesterId == request.auth.uid` and `requestId == request.auth.uid` to enforce one active request document per user and activity.
- Update: only the activity owner for approval/rejection, or the requester for cancellation if that flow is added.
- Deny writes that change `activityId` or `requesterId` after creation.

### `chatThreads/{threadId}`

- Read: only approved participants.
- Create: only trusted backend logic through Cloud Functions.
- Update: only approved participants, limited to coordination-safe fields.

### `chatThreads/{threadId}/messages/{messageId}`

- Read: only approved participants of the parent thread.
- Create: only approved participants with `senderUserId == request.auth.uid`, matching parent `threadId`, and non-empty message text.
- Update/Delete: deny by default for MVP unless an edit/delete product flow is intentionally added.

### `trustEvents/{eventId}`

- Read: only the subject user for user-visible entries.
- Create: authenticated clients only for explicitly allowed user-visible events, otherwise prefer Cloud Functions.
- Internal-only events should move to `moderationEvents` or another private collection.

### `reports/{reportId}` and `blocks/{blockId}`

- Read: only the reporting/blocking user and privileged backend/admin tooling.
- Create: only authenticated users writing their own report or block action; block document ids must be `userId-targetUserId`.
- Public reads must stay denied.

### `moderationEvents/{eventId}`

- Read: deny for normal clients.
- Write: Cloud Functions or privileged moderation tooling only.

### `users/{userId}/notificationTokens/{tokenId}`

- Read/Write: only `request.auth.uid == userId`.
- Token payload should stay minimal and device-scoped.

## Storage Paths

### `profilePhotos/{userId}/...`

- Read: authenticated users if the photo is meant to be public in profile context.
- Write: only the owning user.

### `verification/{userId}/...`

- Read: deny for normal clients unless a future verification review UI requires scoped access.
- Write: only the owning user or trusted backend workflow.

## Validation Priorities

- Use centralized enum names from the app contract.
- Validate ownership ids against `request.auth.uid`.
- Reject documents with unexpected keys where practical.
- Keep approximate-location-only policy enforced at write time for public activity data.

## Function-Owned Writes

Prefer Cloud Functions or server-trusted paths for:

- join request approval side effects
- chat thread creation after approval
- moderation escalation
- internal trust-event writes
- notification fanout

## MVP Rule Checklist

1. Lock down public reads for reports, blocks, and moderation events. Implemented in `firestore.rules`.
2. Limit activity writes to owners. Implemented in `firestore.rules`.
3. Limit join request reads to requester + owner. Implemented in `firestore.rules`.
4. Limit chat reads/writes to approved participants. Implemented in `firestore.rules`.
5. Limit notification token writes to the owning user. Implemented in `firestore.rules`.
6. Keep exact location fields out of public-readable documents. Implemented with write-time rejection for common exact-location field names.
