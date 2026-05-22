# Code Context

## Files Retrieved
1. `anasoil_mobile/lib/main.dart` - mobile entry point: Firebase, DI, router theme.
2. `anasoil_mobile/lib/core/dependency_injection.dart` - GetIt composition root for Services, repository Interfaces/Implementations, ViewModels.
3. `anasoil_mobile/lib/core/router_config.dart` - mobile route Module and auth redirect Seam.
4. `anasoil_mobile/lib/data/repositories/auth/auth_repository.dart` - mobile repository Interface pattern.
5. `anasoil_mobile/lib/data/repositories/document/document_repository.dart` - mobile document repository Interface.
6. `anasoil_mobile/lib/data/repositories/document/document_repository_remote.dart` - Firebase-backed Implementation/Adapter example.
7. `anasoil_mobile/lib/data/services/firestore_service.dart` - mobile Firestore Adapter and mapper-heavy seam.
8. `anasoil_mobile/lib/ui/home/analysis_viewmodel.dart` - mobile Analysis ViewModel: UI commands, document/saved-analysis lists, and delegation to the Analysis Intake workflow.
9. `anasoil_mobile/lib/domain/upload_flow.dart` - current Analysis Intake workflow Module: select/upload document, extract PDF analyses, save one/all extracted analyses.
10. `anasoil_admin/lib/main.dart` - admin entry point: URL strategy, Firebase, locator, router theme.
11. `anasoil_admin/lib/core/service_locator.dart` - admin composition root.
12. `anasoil_admin/lib/core/app_router.dart` - admin route Module, shell layout, auth redirect.
13. `anasoil_admin/lib/core/services/firestore_service.dart` - admin Firestore Adapter for document/analysis persistence after user persistence was extracted.
14. `anasoil_admin/lib/core/stores/user_store.dart` - admin user persistence Seam used by the User Management Module.
15. `anasoil_admin/lib/core/stores/firestore_user_store.dart` - Firestore-backed Adapter for admin user persistence and relation transactions.
16. `anasoil_admin/lib/core/repositories/user_repository.dart` - deepened admin User Management Module: user creation/update, activation/deactivation, relation reads/actions, and cached user list.
17. `anasoil_admin/lib/features/users/viewmodels/user_list_viewmodel.dart` - admin ViewModel pattern now crossing the User Management Module seam.
18. `anasoil_admin/lib/features/documents/viewmodels/document_list_viewmodel.dart` - duplicated admin list ViewModel pattern.
19. `anasoil_admin/lib/core/models/user_model.dart` and `anasoil_mobile/lib/domain/models/user.dart` - duplicated user model shapes.
20. `anasoil_admin/lib/core/models/soil_analysis_model.dart` and `anasoil_mobile/lib/domain/models/soil_analysis.dart` - duplicated analysis model/mapping.
21. `packages/anasoil_shared/lib/src/firestore_schema.dart` - shared Firestore schema constants used by both apps.
22. `anasoil_mobile/pubspec.yaml`, `anasoil_admin/pubspec.yaml` - dependency and test surface.

## Key Code
- Mobile Module layering: `ui/*ViewModel -> data/repositories/* Interface -> *Remote Implementation -> data/services/* Adapter -> Firebase`. DI binds Interfaces to Implementations in `anasoil_mobile/lib/core/dependency_injection.dart`.
- Admin user Module layering after deepening: `features/users/*ViewModel -> core/repositories/UserRepository User Management Module -> core/stores/UserStore Seam -> FirestoreUserStore Adapter + AuthService`. Document and analysis flows still use `features/*/ViewModel -> core/repositories/* cache -> core/services/FirestoreService Adapter`.
- Shared schema Seam exists in `packages/anasoil_shared/lib/src/firestore_schema.dart`: `AnaSoilCollections`, `UserFields`, `DocumentFields`, `AnalysisFields`. Both apps import this for collection/field names.
- Mobile repository Interface example: `abstract class AuthRepository extends ChangeNotifier` with `login/resetPassword/loadCurrentUser/logout` in `anasoil_mobile/lib/data/repositories/auth/auth_repository.dart`. Document has same Interface style in `.../document_repository.dart`.
- Mobile remote Implementation example: `DocumentRepositoryRemote` uploads to Storage, creates Firestore metadata, mutates local list, and notifies listeners in one class (`anasoil_mobile/lib/data/repositories/document/document_repository_remote.dart`).
- Admin user persistence has been extracted from the Firestore mega-Adapter. `FirestoreUserStore` owns user collection converters, user CRUD/status operations, and relation transactions behind the `UserStore` Seam. `FirestoreService` now handles document/analysis streams and soft deletes.

## Architecture
- Major Modules:
  - `anasoil_mobile`: `core` (DI/router/theme), `data/services` (Firebase/Auth/Storage/PDF adapters), `data/repositories` (Auth/Profile/Document/SoilAnalysis Interfaces and remote Implementations), `domain/models`, `ui` feature folders.
  - `anasoil_admin`: `core` (router, service locator, models, repositories, stores, services, theme, URL strategy), `features` (analyses/auth/documents/settings/users pages/viewmodels/widgets), `shared/widgets`.
  - `packages/anasoil_shared`: small shared Kernel for `Result`, `Command`, theme tokens, user roles, Firestore schema.
- Duplicated patterns:
  - `Command` and `Result` are re-exported locally in both apps, already backed by shared package.
  - User/document/soil analysis models are duplicated between admin and mobile with different names and mapper styles (`UserModel` vs `User`, `SoilAnalysisModel` vs `SoilAnalysis`).
  - List ViewModels repeat `fetch -> repository.set -> delete -> refetch -> notify` in admin users/documents/analyses.
  - Both apps have parallel GetIt composition roots and GoRouter auth redirects.
- Shallow Modules / Depth:
  - Admin `UserRepository` has been deepened into a User Management Module. It now gives user ViewModels Leverage through a single seam for save, list, status, delete, linked users, and available relation candidates. Document/analysis repositories remain shallower list caches.
  - Mobile repositories have more Depth: Interface plus Firebase Implementation plus cached state and Result handling.
  - Mobile Analysis Intake has been partly deepened: `AnalysisViewModel` delegates import → upload → extraction → save behaviour to `domain/upload_flow.dart`. Remaining friction is that this workflow Module is still named `UploadFlow`, is Flutter-shaped (`ChangeNotifier`), and splits workflow state across `AnalysisIntakeState` plus separate getters for selected file, uploaded document, extracted analyses, and last saved analyses.
- Seams and Adapters:
  - Strong Seams: mobile repository Interfaces, shared Firestore schema constants, `Result` return type, GetIt roots.
  - Weak Seams: admin document/analysis flows still depend on `FirestoreService` as a concrete Adapter; the user flow now has a stronger `UserStore` Seam with `FirestoreUserStore` as its Adapter.
  - External Adapters: Firebase Auth, Firestore, Firebase Storage, SharedPreferences, Syncfusion PDF extraction, URL strategy web/stub.
- Testing friction:
  - Tests are sparse: mobile has only two domain tests; admin has only `widget_test.dart`.
  - Firebase singletons are constructed inside Services (`FirebaseFirestore.instance`, Firebase Auth/Storage services), making unit tests require mocks or Firebase setup.
  - GetIt globals and singleton ViewModels in mobile increase shared mutable state risk across tests.
  - Admin user ViewModels now depend on `UserRepository`, which depends on the `UserStore` Seam. Document/analysis repositories still depend on concrete `FirestoreService`, so mocking those flows requires refactor or wrappers.
  - Router redirects read global locator state; route tests need locator/Firebase/Auth setup.

## Start Here

### Mobile Start Here
Open `anasoil_mobile/lib/core/dependency_injection.dart`, `anasoil_mobile/lib/domain/upload_flow.dart`, `anasoil_mobile/lib/ui/home/analysis_viewmodel.dart`, and `anasoil_mobile/lib/data/services/firestore_service.dart` first. They show the mobile composition root, the current Analysis Intake workflow Module, ViewModel delegation, repository Interfaces, and Firebase Adapter seams.

### Admin Start Here
Open `anasoil_admin/lib/core/service_locator.dart`, `anasoil_admin/lib/core/repositories/user_repository.dart`, `anasoil_admin/lib/core/stores/user_store.dart`, `anasoil_admin/lib/core/stores/firestore_user_store.dart`, and `anasoil_admin/lib/core/services/firestore_service.dart` when working on admin. They show the current User Management Module seam, the Firestore user Adapter, and the remaining document/analysis Firestore Adapter.
