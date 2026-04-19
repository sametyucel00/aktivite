# Manual QA Checklist

Use this checklist after meaningful feature, repository, or backend-workflow changes.

## Always Check

- open the app and confirm the shell loads without a crash
- confirm signed-out and signed-in entry states behave as expected
- confirm onboarding completion still unlocks the main app surfaces
- edit profile basics and confirm completion progress updates
- upload and remove a profile photo
- verify profile gating copy stays low-pressure and activity-first
- create a plan with valid title, description, city, approximate location, time, and duration
- confirm invalid or clearly incomplete plan input shows useful feedback
- verify exact-location fields are not exposed in public-facing plan UI
- browse explore, map, and activities surfaces
- confirm join CTA states match current rules: open, pending, approved, cancelled, full, and profile-gated
- submit a join request and confirm owner/requester surfaces update as expected
- approve and reject requests from the owner side and confirm the feedback copy is correct
- open the chat surface and confirm the correct thread is selected
- switch between available threads and confirm thread-specific context updates
- send a normal message and confirm preview/update behavior
- verify blocked-thread empty-state copy is safety-oriented and clear
- submit a report using the controlled reason picker
- block a user and confirm affected surfaces stop showing blocked content
- verify the safety timeline still distinguishes visible and internal trust events
- confirm safety summary counts still render correctly
- confirm remote-config-driven labels and safety signals still render
- toggle safe-meetup reminders and verify expected feedback appears
- confirm analytics summary and trust signal surfaces remain readable

## Locale And Platform Spot Checks

- confirm Turkish and English strings still render without overflow in key screens
- Web: shell load, navigation, localization, responsive layout
- Windows: shell load, keyboard input, dialogs, scrolling
- Android: auth entry, image picker flow, location/permission-sensitive surfaces

## When A Firebase Seam Changes

- verify repository-source fallback behavior still works in-memory
- verify affected Firestore and Storage docs still match their contracts
- verify moderation, block, and notification assumptions still match `docs/safety_backend_contracts.md`
