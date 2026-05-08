// lib/core/service_locator.dart
import 'package:anasoil_admin/core/repositories/analysis_repository.dart';
import 'package:anasoil_admin/core/repositories/document_repository.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/services/admin_session.dart';
import 'package:anasoil_admin/core/services/auth_service.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
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
  locator.registerLazySingleton(() => AdminSession(locator<AuthService>()));
  locator.registerLazySingleton(() => FirestoreService());

  // THEME
  locator.registerLazySingleton(() => ThemeProvider());

  // REPOSITORIES
  locator.registerLazySingleton(
    () => UserRepository(locator<FirestoreService>()),
  );
  locator.registerLazySingleton(
    () => DocumentRepository(locator<FirestoreService>()),
  );
  locator.registerLazySingleton(
    () => AnalysisRepository(locator<FirestoreService>()),
  );

  // VIEWMODELS
  locator.registerFactory(() => UserListViewModel(locator<UserRepository>()));
  locator.registerFactory(
    () =>
        UserFormViewModel(locator<FirestoreService>(), locator<AuthService>()),
  );
  locator.registerFactory(
    () => UserRelationViewModel(locator<FirestoreService>()),
  );
  locator.registerFactory(
    () => DocumentListViewModel(locator<DocumentRepository>()),
  );
  locator.registerFactory(
    () => AnalysisListViewModel(locator<AnalysisRepository>()),
  );
}
