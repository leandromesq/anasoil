import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/services/auth_service.dart';
import 'package:anasoil_admin/features/auth/pages/login_page.dart';
import 'package:anasoil_admin/features/users/pages/user_form_page.dart';
import 'package:anasoil_admin/features/users/pages/user_list_page.dart';
import 'package:anasoil_admin/features/users/pages/user_relation_page.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_list_viewmodel.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_relation_viewmodel.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/users',
    refreshListenable: locator<AuthService>(),
    redirect: (context, state) {
      final isAuthenticated = locator<AuthService>().isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginRoute) return '/login';
      if (isAuthenticated && isLoginRoute) return '/users';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/users',
        builder: (context, state) =>
            UserListPage(viewModel: locator<UserListViewModel>()),
      ),
      GoRoute(
        path: '/user/add',
        builder: (context, state) => const UserFormPage(),
      ),
      GoRoute(
        path: '/user/edit/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserFormPage(userId: userId);
        },
      ),
      GoRoute(
        path: '/user/:userId/relations',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserRelationPage(
            userId: userId,
            viewModel: locator<UserRelationViewModel>(),
          );
        },
      ),
    ],
  );
}
