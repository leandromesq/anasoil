// lib/core/service_locator.dart
import 'package:anasoil_admin/core/auth/user_auth_gateway.dart';
import 'package:anasoil_admin/core/repositories/analysis_repository.dart';
import 'package:anasoil_admin/core/repositories/document_repository.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/services/admin_session.dart';
import 'package:anasoil_admin/core/services/auth_service.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:anasoil_admin/core/stores/firestore_user_store.dart';
import 'package:anasoil_admin/core/stores/user_store.dart';
import 'package:anasoil_admin/features/analyses/viewmodels/analysis_list_viewmodel.dart';
import 'package:anasoil_admin/features/documents/viewmodels/document_list_viewmodel.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_form_viewmodel.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_list_viewmodel.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_relation_viewmodel.dart';
import 'package:get_it/get_it.dart';

import 'package:anasoil_admin/core/theme/theme_provider.dart';

final locator = GetIt.instance;

void setupLocator() {
  // SERVICES
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton<UserAuthGateway>(() => locator<AuthService>());
  locator.registerLazySingleton(() => AdminSession(locator<AuthService>()));
  locator.registerLazySingleton(() => FirestoreService());
  locator.registerLazySingleton<UserStore>(() => FirestoreUserStore());

  // THEME
  locator.registerLazySingleton(() => ThemeProvider());

  // REPOSITORIES
  locator.registerLazySingleton(
    () => UserRepository(locator<UserStore>(), locator<UserAuthGateway>()),
  );
  locator.registerLazySingleton(
    () => DocumentRepository(locator<FirestoreService>()),
  );
  locator.registerLazySingleton(
    () => AnalysisRepository(locator<FirestoreService>()),
  );

  // VIEWMODELS
  locator.registerFactory(() => UserListViewModel(locator<UserRepository>()));
  locator.registerFactory(() => UserFormViewModel(locator<UserRepository>()));
  locator.registerFactory(
    () => UserRelationViewModel(locator<UserRepository>()),
  );
  locator.registerFactory(
    () => DocumentListViewModel(locator<DocumentRepository>()),
  );
  locator.registerFactory(
    () => AnalysisListViewModel(locator<AnalysisRepository>()),
  );
}
