import 'dart:async';

import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/stores/user_store.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// Provides synchronous decisions for the admin router, sidebar and write guards
/// without reaching into [AuthService] directly.
class AdminSession extends ChangeNotifier {
  final AuthService _authService;
  final UserStore _userStore;

  UserModel? _currentUserProfile;
  StreamSubscription<UserModel?>? _profileSubscription;
  bool _isLoadingProfile = false;
  int _profileLoadVersion = 0;

  AdminSession(this._authService, this._userStore) {
    _authService.addListener(_syncAuthenticatedUser);
    _syncAuthenticatedUser();
  }

  bool get isAuthenticated => _authService.isAuthenticated;
  String? get email => _authService.currentUser?.email;
  UserModel? get currentUserProfile => _currentUserProfile;
  UserRole? get currentUserRole => _currentUserProfile?.userRole;
  bool get isLoadingProfile => _isLoadingProfile;

  bool get canManageData => currentUserRole == UserRole.admin;
  bool get canManageRelations =>
      currentUserRole == UserRole.admin ||
      currentUserRole == UserRole.consultant;

  /// Whether the current request should redirect to login.
  bool get shouldRedirectToLogin =>
      !isAuthenticated || _authService.currentUser?.email == null;

  /// Whether the current request should redirect away from public routes.
  bool get shouldRedirectFromPublic => isAuthenticated;

  void ensureCanManageData() {
    if (!canManageData) {
      throw Exception('Apenas administradores podem editar ou excluir dados.');
    }
  }

  void ensureCanManageRelations({String? consultantId}) {
    if (!canManageRelations) {
      throw Exception(
        'Apenas administradores e consultores podem gerenciar relações.',
      );
    }

    if (currentUserRole == UserRole.consultant &&
        consultantId != null &&
        consultantId != _currentUserProfile?.id) {
      throw Exception(
        'Consultores só podem gerenciar relações vinculadas ao próprio perfil.',
      );
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _syncAuthenticatedUser() {
    final version = ++_profileLoadVersion;
    final currentEmail = email;
    final currentUserId = _authService.currentUserId;

    _profileSubscription?.cancel();
    _profileSubscription = null;

    if (!isAuthenticated || currentEmail == null || currentUserId == null) {
      _currentUserProfile = null;
      _isLoadingProfile = false;
      notifyListeners();
      return;
    }

    _isLoadingProfile = true;
    notifyListeners();

    _profileSubscription = _userStore
        .getUserById(currentUserId)
        .listen(
          (profile) async {
            if (version != _profileLoadVersion) return;

            _currentUserProfile =
                profile ?? await _userStore.getUserByEmail(currentEmail);
            _isLoadingProfile = false;
            notifyListeners();
          },
          onError: (_) async {
            if (version != _profileLoadVersion) return;

            _currentUserProfile = await _userStore.getUserByEmail(currentEmail);
            _isLoadingProfile = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _authService.removeListener(_syncAuthenticatedUser);
    super.dispose();
  }
}
