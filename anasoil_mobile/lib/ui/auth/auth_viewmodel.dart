import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/login_credentials.dart';
import '../../../domain/models/register_data.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel de autenticação
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // Escuta mudanças no repository para atualizar a UI
    _authRepository.addListener(notifyListeners);

    // Inicializa commands
    loginCommand = Command1(_login);
    registerCommand = Command1(_register);
    resetPasswordCommand = Command1(_resetPassword);
    loadUserCommand = Command0(_authRepository.loadCurrentUser);
    logoutCommand = Command0(_authRepository.logout);
  }

  // Commands
  late final Command1<User, LoginCredentials> loginCommand;
  late final Command1<User, RegisterData> registerCommand;
  late final Command1<void, String> resetPasswordCommand;
  late final Command0<User?> loadUserCommand;
  late final Command0<void> logoutCommand;

  /// Usuário atual
  User? get currentUser => _authRepository.currentUser;

  /// Verifica se há usuário autenticado
  bool get isAuthenticated => _authRepository.isAuthenticated;

  /// Realiza o login
  Future<Result<User>> _login(LoginCredentials credentials) async {
    return await _authRepository.login(credentials);
  }

  /// Registra um novo usuário
  Future<Result<User>> _register(RegisterData data) async {
    return await _authRepository.register(data);
  }

  /// Recupera a senha
  Future<Result<void>> _resetPassword(String email) async {
    return await _authRepository.resetPassword(email);
  }

  @override
  void dispose() {
    _authRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
