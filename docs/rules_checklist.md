# Rules Checklist

This checklist is the operational bridge between the human-readable rule docs and the concrete rule files.

Use it to answer three questions quickly:

1. is the boundary already implemented in `firestore.rules` or `storage.rules`?
2. is the boundary documented clearly enough for reviewers?
3. does the emulator scaffold already have a named assertion slot for it?

## Firestore Checklist

| Boundary | Implemented | Rule file | Emulator status | Notes |
| --- | --- | --- | --- | --- |
| Profiles are writable only by the owning user | Yes | `firestore.rules` | Pending | `profiles/{userId}` requires `request.auth.uid == userId` and matching `id` |
| Notification tokens are user-scoped | Yes | `firestore.rules` | Pending | `users/{userId}/notificationTokens/{tokenId}` is self-scoped |
| Activity create requires owner identity and non-empty core text | Yes | `firestore.rules` | Pending | `createsOwnActivity(activityId)` |
| Activity create rejects exact public location fields | Yes | `firestore.rules` | Pending | `publicActivityHasNoExactLocation()` |
| Activity update is limited to narrow client fallback metadata | Yes | `firestore.rules` | Pending | participant count, status, workflow source, updated time |
| Join request create is deterministic per requester and activity | Yes | `firestore.rules` | Named skip exists | request id must equal `request.auth.uid` |
| Join request reads are limited to owner and requester | Yes | `firestore.rules` | Pending | owner/requester visibility only |
| Join request update can only change status workflow fields | Yes | `firestore.rules` | Pending | approval/rejection/cancellation only |
| Chat thread creation is backend-owned | Yes | `firestore.rules` | Named skip exists | direct client create denied |
| Chat thread update is limited to preview metadata | Yes | `firestore.rules` | Pending | `lastMessagePreview` and `updatedAt` only |
| Chat message create requires participant membership and bounded text | Yes | `firestore.rules` | Named skip exists | non-empty text, max 280 chars |
| Trust events only expose user-visible self records | Yes | `firestore.rules` | Pending | internal events stay out of client reads |
| Reports are private and canonical-reason only | Yes | `firestore.rules` | Named skip exists | self-targeted reports denied, reasons whitelisted |
| Blocks are private and use deterministic ids | Yes | `firestore.rules` | Named skip exists | `userId-targetUserId` |
| Moderation events are denied for normal clients | Yes | `firestore.rules` | Pending | privileged/backend only |
| Default catch-all deny remains active | Yes | `firestore.rules` | Pending | final wildcard deny |

## Storage Checklist

| Boundary | Implemented | Rule file | Emulator status | Notes |
| --- | --- | --- | --- | --- |
| Profile photos require auth + own path | Yes | `storage.rules` | Pending | `profilePhotos/{userId}/...` |
| Profile photos require supported image types and size | Yes | `storage.rules` | Pending | jpeg/png/webp under 5 MB |
| Verification uploads require auth + own path | Yes | `storage.rules` | Pending | `verification/{userId}/...` |
| Verification reads are denied for normal clients | Yes | `storage.rules` | Pending | no client read access |
| Default catch-all deny remains active | Yes | `storage.rules` | Pending | final wildcard deny |

## Emulator Readiness

Current scaffold already covers named starting points for:

- owner activity create
- deterministic join request ids
- backend-owned chat threads with participant-only messages
- invalid report reasons and invalid block ids

Still missing named scaffold coverage for:

- profile document ownership
- notification token ownership
- activity update immutable-field enforcement
- trust-event visibility
- moderation-event deny behavior
- storage rules scenarios

## Update Rule

Whenever a rule boundary changes:

1. update `firestore.rules` or `storage.rules`
2. update `docs/security_rules.md`
3. update this checklist
4. add or rename the matching emulator scaffold assertion when applicable
