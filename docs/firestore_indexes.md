# Firestore Index Plan

This document lists Firestore index needs based on the current discovery, ownership, join-request, chat, and safety seams. The first concrete index config lives in `firestore.indexes.json`.

## Activities

Expected query families:

- discover open plans by surface
- discover plans by surface + category
- read owned plans by `ownerUserId`
- sort/filter by status when needed

Likely index combinations:

1. `activities`
   - `surfaces` array-contains
   - `status` ascending

2. `activities`
   - `surfaces` array-contains
   - `category` ascending
   - `status` ascending

3. `activities`
   - `ownerUserId` ascending
   - `status` ascending

4. `activities`
   - `ownerUserId` ascending
   - `timeOption` ascending

Notes:

- Discovery ranking currently happens in memory after provider filtering.
- If distance/time ordering moves to Firestore later, new indexes will be needed.

## Join Requests

Expected query families:

- read join requests for one activity
- read join requests for one activity filtered by status

Likely index combinations:

1. `activities/{activityId}/joinRequests`
   - `status` ascending

Notes:

- Per-activity subcollection reads may not need a composite index until status filtering or ordering is added.

## Chat Threads

Expected query families:

- read chat threads for one participant
- optionally sort by recent activity when backend timestamps are added

Likely index combinations:

1. `chatThreads`
   - `participantIds` array-contains

2. `chatThreads`
   - `participantIds` array-contains
   - `updatedAt` descending

Notes:

- The current in-memory seam filters blocked users after read.
- If backend filtering becomes query-driven, additional fields and indexes may be required.

## Messages

Expected query families:

- read messages inside one thread ordered by `sentAt`

Likely index combinations:

1. `chatThreads/{threadId}/messages`
   - `sentAt` ascending

Notes:

- Single-field ordering may be enough unless moderation status or soft-delete flags are added.

## Trust Events And Moderation

Expected query families:

- read trust events for one subject user
- optionally sort by newest first

Likely index combinations:

1. `trustEvents`
   - `subjectUserId` ascending
   - `createdAt` descending

2. `moderationEvents`
   - `subjectUserId` ascending
   - `createdAt` descending

## Reports And Blocks

Expected query families:

- read reports created by a specific user in self-service history
- read blocks for the blocking user

Likely index combinations:

1. `reports`
   - `userId` ascending
   - `createdAt` descending

2. `blocks`
   - `userId` ascending
   - `createdAt` descending

Current `firestore.indexes.json` already matches these user-scoped safety indexes.

## Migration Guidance

1. Add indexes only when the Firebase implementation introduces the matching query.
2. Keep index definitions scoped to one repository migration at a time.
3. Update this document when a query shape changes.
4. Keep `firestore.indexes.json` and this document aligned whenever a query shape changes.
