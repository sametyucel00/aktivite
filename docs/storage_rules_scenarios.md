# Storage Rules Scenarios

This document captures the first storage-rule cases the repository should protect before Firebase-backed media flows become the default.

## Profile Photos

Path family:

- `profilePhotos/{userId}/...`

Expected allow cases:

- authenticated user uploads under their own `userId`
- authenticated user replaces or deletes their own profile photo
- authenticated clients can read public profile photos when the product intentionally exposes them

Expected deny cases:

- anonymous user upload
- user uploading to another user path
- write attempts outside the approved profile-photo path family

## Verification Media

Path family:

- `verification/{userId}/...`

Expected allow cases:

- authenticated user uploads their own verification evidence
- trusted backend workflow writes scoped verification outputs if later required

Expected deny cases:

- normal client reading another user’s verification evidence
- anonymous upload
- user writing under another user’s verification path

## Future Attachments

If the product later adds report attachments or trusted-contact/safe-return media:

- create separate private path families
- default reads to deny
- avoid reusing public profile-photo paths for safety-sensitive uploads

## Test Guidance

When expanding emulator-backed Storage tests, continue with:

1. own profile-photo upload allowed
2. cross-user profile-photo upload denied
3. own verification upload allowed
4. verification read denied for normal clients

Keep these scenarios aligned with `storage.rules`, `docs/security_rules.md`, and `docs/testing.md`.
