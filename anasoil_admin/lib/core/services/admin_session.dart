import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// Provides synchronous decisions for the admin router and sidebar without
/// reaching into [AuthService] directly. The router redirect callback and
/// sidebar both use this module instead of inspecting AuthService internals.
class AdminSession extends ChangeNotifier {
  final AuthService _authService;

  AdminSession(this._authService) {
    _authService.addListener(notifyListeners);
  }

  bool get isAuthenticated => _authService.isAuthenticated;
  String? get email => _authService.currentUser?.email;

  /// Whether the current request should redirect to login.
  bool get shouldRedirectToLogin =>
      !isAuthenticated || _authService.currentUser?.email == null;

  /// Whether the current request should redirect away from public routes.
  bool get shouldRedirectFromPublic => isAuthenticated;

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authService.removeListener(notifyListeners);
    super.dispose();
  }
}
