# Repository Source Comparison

This is the short reference table for how `RepositorySource.inMemory` and `RepositorySource.firebase` differ today.

## Quick Comparison

| Seam | `inMemory` | `firebase` |
| --- | --- | --- |
| Auth | demo-friendly local auth state | real Firebase Auth identity and session state |
| Profiles | local stream-backed sample/current profile state | Firestore-backed profile documents |
| Activities | local create/read/update with deterministic in-process streams | Firestore-backed activity docs with server timestamps |
| Join requests | local no-op guard for invalid or duplicate active requests | Firestore-backed user-scoped request docs, signed-in user required |
| Chat send | local no-op for blank/unknown-thread writes | signed-in Firebase user required, sender derived from auth |
| Chat thread create | local fallback can create thread for approval flow | backend-owned through Cloud Functions |
| Safety report/block | local normalized no-op behavior for invalid/self payloads | normalized before Firestore write, still no-op for invalid/self payloads |
| Moderation/trust events | local seeded stream behavior | intended Firestore-backed event streams |
| Analytics | in-memory event log for tests and local UX summaries | Firebase Analytics events |
| Remote config | local fallback values | Firebase Remote Config values |

## Behavior Notes

| Concern | `inMemory` | `firebase` |
| --- | --- | --- |
| Invalid payloads | usually silent no-op | silent no-op before write unless auth/backend dependency is required |
| Auth requirement | often optional for local scaffolding | required for user-owned writes |
| Timestamp source | Dart `DateTime` in process | Firestore server timestamps normalized into Dart models |
| Side effects | local fallback only where intentionally supported | privileged workflows should move to Cloud Functions |
| Test style | Flutter unit/widget/provider tests | repository mapper tests, rules tests, function tests, emulator checks |

## When To Use

- Use `RepositorySource.inMemory` for daily scaffold-safe development, widget iteration, and deterministic local tests.
- Use `RepositorySource.firebase` only when the specific seam is implemented, documented, and verified end-to-end.

For the longer repository-to-collection contract, use `docs/backend_contracts.md`.
