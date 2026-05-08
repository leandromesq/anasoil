# Code Context

## Files Retrieved
1. `anasoil_mobile/lib/main.dart` (lines 1-32) - mobile entry point: Firebase, DI, router theme.
2. `anasoil_mobile/lib/core/dependency_injection.dart` (lines 22-93) - GetIt composition root for Services, repository Interfaces/Implementations, ViewModels.
3. `anasoil_mobile/lib/core/router_config.dart` (lines 23-150) - mobile route Module and auth redirect Seam.
4. `anasoil_mobile/lib/data/repositories/auth/auth_repository.dart` (lines 7-24) - mobile repository Interface pattern.
5. `anasoil_mobile/lib/data/repositories/document/document_repository.dart` (lines 7-18) - mobile document repository Interface.
6. `anasoil_mobile/lib/data/repositories/document/document_repository_remote.dart` (lines 9-123) - Firebase-backed Implementation/Adapter example.
7. `anasoil_mobile/lib/data/services/firestore_service.dart` (lines 1-200) - mobile Firestore Adapter and mapper-heavy boundary.
8. `anasoil_mobile/lib/ui/home/analysis_viewmodel.dart` (lines 12-240) - deepest mobile workflow Module: upload, extract, save analysis.
9. `anasoil_admin/lib/main.dart` (lines 1-35) - admin entry point: URL strategy, Firebase, locator, router theme.
10. `anasoil_admin/lib/core/service_locator.dart` (lines 18-53) - admin composition root.
11. `anasoil_admin/lib/core/app_router.dart` (lines 22-151) - admin route Module, shell layout, auth redirect.
12. `anasoil_admin/lib/core/services/firestore_service.dart` (lines 9-305) - admin Firestore Adapter with typed converters and user relation rules.
13. `anasoil_admin/lib/core/repositories/user_repository.dart` (lines 4-16) - shallow state repository example.
14. `anasoil_admin/lib/features/users/viewmodels/user_list_viewmodel.dart` (lines 8-51) - admin ViewModel pattern.
15. `anasoil_admin/lib/features/documents/viewmodels/document_list_viewmodel.dart` (lines 8-39) - duplicated admin list ViewModel pattern.
16. `anasoil_admin/lib/core/models/user_model.dart` (lines 1-65) and `anasoil_mobile/lib/domain/models/user.dart` (lines 1-67) - duplicated user model shapes.
17. `anasoil_admin/lib/core/models/soil_analysis_model.dart` (lines 1-120) and `anasoil_mobile/lib/domain/models/soil_analysis.dart` (lines 1-120) - duplicated analysis model/mapping.
18. `packages/anasoil_shared/lib/src/firestore_schema.dart` (lines 2-63) - shared Firestore schema constants used by both apps.
19. `anasoil_mobile/pubspec.yaml` (lines 1-57), `anasoil_admin/pubspec.yaml` (lines 1-75) - dependency and test surface.

## Key Code
- Mobile Module layering: `ui/*ViewModel -> data/repositories/* Interface -> *Remote Implementation -> data/services/* Adapter -> Firebase`. DI binds Interfaces to Implementations in `anasoil_mobile/lib/core/dependency_injection.dart` (lines 25-93).
- Admin Module layering: `features/*/ViewModel -> core/repositories/* shallow cache -> core/services/FirestoreService Adapter`; many ViewModels also call `FirestoreService` directly, e.g. `UserListViewModel` (lines 9-45), reducing Interface value.
- Shared schema Seam exists in `packages/anasoil_shared/lib/src/firestore_schema.dart`: `AnaSoilCollections`, `UserFields`, `DocumentFields`, `AnalysisFields` (lines 2-63). Both apps import this for collection/field names.
- Mobile repository Interface example: `abstract class AuthRepository extends ChangeNotifier` with `login/resetPassword/loadCurrentUser/logout` in `anasoil_mobile/lib/data/repositories/auth/auth_repository.dart` (lines 7-24). Document has same Interface style in `.../document_repository.dart` (lines 7-18).
- Mobile remote Implementation example: `DocumentRepositoryRemote` uploads to Storage, creates Firestore metadata, mutates local list, and notifies listeners in one class (`anasoil_mobile/lib/data/repositories/document/document_repository_remote.dart`, lines 9-123).
- Admin Firestore Adapter is central and deep: typed collection converters at lines 18-38; user CRUD/status/relation rules at lines 41-253; document/analysis streams and soft deletes at lines 273-305.

## Architecture
- Major Modules:
  - `anasoil_mobile`: `core` (DI/router/theme), `data/services` (Firebase/Auth/Storage/PDF adapters), `data/repositories` (Auth/Profile/Document/SoilAnalysis Interfaces and remote Implementations), `domain/models`, `ui` feature folders.
  - `anasoil_admin`: `core` (router, service locator, models, repositories, services, theme, URL strategy), `features` (analyses/auth/documents/settings/users pages/viewmodels/widgets), `shared/widgets`.
  - `packages/anasoil_shared`: small shared Kernel for `Result`, `Command`, theme tokens, user roles, Firestore schema.
- Duplicated patterns:
  - `Command` and `Result` are re-exported locally in both apps, already backed by shared package.
  - User/document/soil analysis models are duplicated between admin and mobile with different names and mapper styles (`UserModel` vs `User`, `SoilAnalysisModel` vs `SoilAnalysis`).
  - List ViewModels repeat `fetch -> repository.set -> delete -> refetch -> notify` in admin users/documents/analyses.
  - Both apps have parallel GetIt composition roots and GoRouter auth redirects.
- Shallow Modules / Depth:
  - Admin `core/repositories/*` are shallow caches (`UserRepository` only stores list and notifies, lines 4-16). Low Depth and questionable Leverage because ViewModels still depend on `FirestoreService` directly.
  - Mobile repositories have more Depth: Interface plus Firebase Implementation plus cached state and Result handling.
  - Mobile `AnalysisViewModel` has high Depth but low Locality: UI state machine, upload, PDF extraction, persistence, and batch save are in one ViewModel.
- Seams and Adapters:
  - Strong Seams: mobile repository Interfaces, shared Firestore schema constants, `Result` return type, GetIt roots.
  - Weak Seams: admin lacks repository Interfaces for Firestore operations; `FirestoreService` is a concrete mega-Adapter.
  - External Adapters: Firebase Auth, Firestore, Firebase Storage, SharedPreferences, Syncfusion PDF extraction, URL strategy web/stub.
- Testing friction:
  - Tests are sparse: mobile has only two domain tests; admin has only `widget_test.dart`.
  - Firebase singletons are constructed inside Services (`FirebaseFirestore.instance`, Firebase Auth/Storage services), making unit tests require mocks or Firebase setup.
  - GetIt globals and singleton ViewModels in mobile increase shared mutable state risk across tests.
  - Admin ViewModels depend on concrete `FirestoreService`, not an Interface, so mocking requires refactor or wrappers.
  - Router redirects read global locator state; route tests need locator/Firebase/Auth setup.

## Start Here
Open `anasoil_mobile/lib/core/dependency_injection.dart` and `anasoil_admin/lib/core/service_locator.dart` first. They show Module boundaries, Interfaces versus concrete Implementations, and the highest-Leverage seams for reducing duplication and improving testability.
