// lib/core/service_locator.dart
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_form_viewmodel.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_list_viewmodel.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocator() {
  // SERVICES
  locator.registerLazySingleton(() => FirestoreService());

  // REPOSITORIES
  locator.registerLazySingleton(() => UserRepository());

  // VIEWMODELS
  locator.registerFactory(
    () => UserListViewModel(
      locator<UserRepository>(),
      locator<FirestoreService>(),
    ),
  );
  locator.registerFactory(() => UserFormViewModel(locator<FirestoreService>()));
}
