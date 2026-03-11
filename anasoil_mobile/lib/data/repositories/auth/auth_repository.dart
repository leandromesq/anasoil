import 'package:flutter/foundation.dart';
import '../../../domain/models/user.dart';
import '../../../domain/models/login_credentials.dart';
import '../../../utils/result.dart';

/// Interface do repositório de autenticação
abstract class AuthRepository extends ChangeNotifier {
  /// Usuário atual autenticado
  User? get currentUser;

  /// Verifica se há um usuário autenticado
  bool get isAuthenticated;

  /// Realiza o login do usuário
  Future<Result<User>> login(LoginCredentials credentials);

  /// Recupera a senha do usuário
  Future<Result<void>> resetPassword(String email);

  /// Carrega o usuário atual do storage
  Future<Result<User?>> loadCurrentUser();

  /// Realiza o logout do usuário
  Future<Result<void>> logout();
}
