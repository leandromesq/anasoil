import 'package:anasoil_admin/core/service_locator.dart';
import 'package:anasoil_admin/core/services/admin_session.dart';
import 'package:anasoil_admin/features/analyses/pages/analysis_detail_page.dart';
import 'package:anasoil_admin/features/analyses/pages/analysis_list_page.dart';
import 'package:anasoil_admin/features/analyses/viewmodels/analysis_list_viewmodel.dart';
import 'package:anasoil_admin/features/auth/pages/change_password_page.dart';
import 'package:anasoil_admin/features/auth/pages/login_page.dart';
import 'package:anasoil_admin/features/auth/pages/reset_password_page.dart';
import 'package:anasoil_admin/features/documents/pages/document_detail_page.dart';
import 'package:anasoil_admin/features/documents/pages/document_list_page.dart';
import 'package:anasoil_admin/features/documents/viewmodels/document_list_viewmodel.dart';
import 'package:anasoil_admin/features/settings/pages/settings_page.dart';
import 'package:anasoil_admin/features/users/pages/user_form_page.dart';
import 'package:anasoil_admin/features/users/pages/user_list_page.dart';
import 'package:anasoil_admin/features/users/pages/user_relation_page.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_list_viewmodel.dart';
import 'package:anasoil_admin/features/users/viewmodels/user_relation_viewmodel.dart';
import 'package:anasoil_admin/shared/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/users',
    refreshListenable: locator<AdminSession>(),
    redirect: (context, state) {
      final session = locator<AdminSession>();
      final isLoginRoute = state.matchedLocation == '/login';
      final isResetRoute = state.matchedLocation == '/reset-password';
      final isChangePasswordRoute = state.matchedLocation == '/change-password';

      if (!session.isAuthenticated &&
          !isLoginRoute &&
          !isResetRoute &&
          !isChangePasswordRoute) {
        return '/login';
      }

      if (session.shouldRedirectToLogin && !isChangePasswordRoute) {
        return '/login';
      }

      if (session.shouldRedirectFromPublic && (isLoginRoute || isResetRoute)) {
        return '/users';
      }

      if (session.isAuthenticated && session.isLoadingProfile) {
        return null;
      }

      final route = state.uri.path;
      if ((route == '/user/add' || route.startsWith('/user/edit/')) &&
          !session.canManageData) {
        return '/users';
      }

      if (route.endsWith('/relations') && !session.canManageRelations) {
        return '/users';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) {
          final oobCode = state.uri.queryParameters['oobCode'] ?? '';
          return ChangePasswordPage(oobCode: oobCode);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/users',
            pageBuilder: (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: UserListPage(viewModel: locator<UserListViewModel>()),
            ),
          ),
          GoRoute(
            path: '/user/add',
            pageBuilder: (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: const UserFormPage(),
            ),
          ),
          GoRoute(
            path: '/user/edit/:userId',
            pageBuilder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return _fadeTransitionPage(
                key: state.pageKey,
                child: UserFormPage(userId: userId),
              );
            },
          ),
          GoRoute(
            path: '/user/:userId/relations',
            pageBuilder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return _fadeTransitionPage(
                key: state.pageKey,
                child: UserRelationPage(
                  userId: userId,
                  viewModel: locator<UserRelationViewModel>(),
                ),
              );
            },
          ),
          GoRoute(
            path: '/documents',
            pageBuilder: (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: DocumentListPage(
                viewModel: locator<DocumentListViewModel>(),
              ),
            ),
          ),
          GoRoute(
            path: '/document/:documentId',
            pageBuilder: (context, state) {
              final documentId = state.pathParameters['documentId']!;
              return _fadeTransitionPage(
                key: state.pageKey,
                child: DocumentDetailPage(documentId: documentId),
              );
            },
          ),
          GoRoute(
            path: '/analyses',
            pageBuilder: (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: AnalysisListPage(
                viewModel: locator<AnalysisListViewModel>(),
              ),
            ),
          ),
          GoRoute(
            path: '/analysis/:analysisId',
            pageBuilder: (context, state) {
              final analysisId = state.pathParameters['analysisId']!;
              return _fadeTransitionPage(
                key: state.pageKey,
                child: AnalysisDetailPage(analysisId: analysisId),
              );
            },
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => _fadeTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );

  static NoTransitionPage _fadeTransitionPage({
    required LocalKey key,
    required Widget child,
  }) {
    return NoTransitionPage(key: key, child: child);
  }
}
