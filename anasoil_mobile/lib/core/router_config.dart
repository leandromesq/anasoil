import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/dependency_injection.dart';
import '../data/repositories/auth/auth_repository.dart';
import '../domain/models/document.dart';
import '../domain/models/soil_analysis.dart';
import '../domain/models/user.dart';
import '../ui/auth/auth_viewmodel.dart';
import '../ui/auth/login_page.dart';
import '../ui/auth/reset_password_page.dart';
import '../ui/auth/splash_page.dart';
import '../ui/analysis/analysis_detail_page.dart';
import '../ui/documents/documents_page.dart';
import '../ui/documents/pdf_preview_page.dart';
import '../ui/farmers/farmer_analyses_page.dart';
import '../ui/farmers/farmers_list_page.dart';
import '../ui/home/main_scaffold.dart';
import '../ui/profile/profile_viewmodel.dart';
import '../ui/profile/edit_profile_page.dart';
import '../ui/profile/change_password_page.dart';

/// Configuração de rotas do app com GoRouter
final goRouter = GoRouter(
  initialLocation: '/splash',
  redirect: _handleRedirect,
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    // Auth Routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginPage(viewModel: getIt<AuthViewModel>()),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) =>
          ResetPasswordPage(viewModel: getIt<AuthViewModel>()),
    ),

    // Home (Main Scaffold com Bottom Navigation)
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => MainScaffold(
        authViewModel: getIt<AuthViewModel>(),
        profileViewModel: getIt<ProfileViewModel>(),
      ),
    ),

    // Profile Routes (páginas separadas)
    GoRoute(
      path: '/profile/edit',
      name: 'profile-edit',
      builder: (context, state) =>
          EditProfilePage(viewModel: getIt<ProfileViewModel>()),
    ),
    GoRoute(
      path: '/profile/change-password',
      name: 'profile-change-password',
      builder: (context, state) =>
          ChangePasswordPage(viewModel: getIt<ProfileViewModel>()),
    ),

    // Documents Routes
    GoRoute(
      path: '/documents',
      name: 'documents',
      builder: (context, state) => const DocumentsPage(),
    ),
    GoRoute(
      path: '/documents/preview',
      name: 'documents-preview',
      builder: (context, state) {
        final doc = state.extra as SoilDocument;
        return PdfPreviewPage(document: doc);
      },
    ),

    // Farmers Routes
    GoRoute(
      path: '/farmers',
      name: 'farmers',
      builder: (context, state) => const FarmersListPage(),
    ),
    GoRoute(
      path: '/farmers/:farmerId',
      name: 'farmer-analyses',
      builder: (context, state) {
        final farmer = state.extra as User;
        return FarmerAnalysesPage(farmer: farmer);
      },
    ),

    // Analysis Detail
    GoRoute(
      path: '/analysis/detail',
      name: 'analysis-detail',
      builder: (context, state) {
        final analysis = state.extra as SoilAnalysis;
        return AnalysisDetailPage(analysis: analysis);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página não encontrada: ${state.matchedLocation}'),
    ),
  ),
);

/// Manipula redirecionamentos baseados no estado de autenticação
Future<String?> _handleRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  final authRepository = getIt<AuthRepository>();
  final currentLocation = state.matchedLocation;

  // Páginas públicas que não requerem autenticação
  const publicRoutes = ['/login', '/reset-password'];

  // Se está na splash, redirecionar com base na autenticação
  if (currentLocation == '/splash') {
    if (authRepository.isAuthenticated) {
      return '/home';
    } else {
      return '/login';
    }
  }

  // Se não está autenticado e tenta acessar página privada
  if (!authRepository.isAuthenticated &&
      !publicRoutes.contains(currentLocation)) {
    return '/login';
  }

  // Se está autenticado e tenta acessar página pública
  if (authRepository.isAuthenticated &&
      publicRoutes.contains(currentLocation)) {
    return '/home';
  }

  // Não redirecionar
  return null;
}
