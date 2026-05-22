# ADR-0001: Deepen Admin User Management Module

## Status

Accepted

## Context

`anasoil_admin/usecase.md` defines **Gerenciar Usuários** as a coherent admin use case: list users, create users, edit users, assign profiles, and deactivate users. The implementation previously spread this behaviour across user ViewModels, `UserRepository`, `AuthService`, and a broad `FirestoreService` Adapter.

This made the user-management seam too low. ViewModels knew concrete Firebase-facing modules, while user rules such as duplicate email checks, last-admin protection, relation validation, and soft delete were mixed with Firestore persistence code.

## Decision

Admin user management will be modelled as a deeper `UserRepository` Module.

The intended layering is:

```txt
User ViewModels
  ↓
UserRepository
  ↓
UserStore seam + user-auth seam
  ↓
FirestoreUserStore Adapter + AuthService Adapter
```

`UserRepository` owns use-case behaviour and rules:

- email normalization before create/update
- duplicate email rejection
- Auth account creation before Firestore user document creation
- profile/role update rules
- soft delete by setting `active = false`
- self-delete/self-deactivation rejection
- last active admin protection
- farmer/consultant relation use-case validation
- cached user list refresh after mutations

`UserStore` is the persistence seam. Its Firestore Adapter should own Firestore mechanics:

- collection converters
- queries
- document writes
- transactions
- `arrayUnion` / `arrayRemove`

`FirestoreUserStore` may keep minimal defensive validation inside transactions when needed to preserve persistence integrity, but use-case decisions belong in `UserRepository`.

## Consequences

- User ViewModels cross a higher-leverage seam and no longer need to know Firestore details.
- User-management rules become testable without Firebase by using fake `UserStore` and user-auth Adapters.
- `FirestoreService` is reduced toward focused document/analysis persistence instead of being a user/document/analysis mega Adapter.
- More seams exist, so names must stay disciplined: `UserRepository` is the User Management Module; `UserStore` is persistence; `FirestoreUserStore` is the Firestore Adapter.

## Follow-ups

- Introduce a user-auth seam for `createAuthUser` and current admin identity.
- Move remaining user rules from `FirestoreUserStore` into `UserRepository`.
- Add self-delete/self-deactivation protection.
- Add `UserRepository` unit tests for the `Gerenciar Usuários` use case.
- Update `anasoil_admin/usecase.md` to reflect the reset-email password flow and any relation-management use case scope.
