import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/features/users/pages/user_form_page.dart';
import 'package:anasoil_admin/features/users/pages/user_list_page.dart';
import 'package:anasoil_admin/features/users/pages/user_relation_page.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_list_viewmodel.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/users',
    routes: [
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
          return UserRelationPage(userId: userId);
        },
      ),
    ],
  );
}
