import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../utils/result.dart';

/// Serviço de autenticação com Firebase
class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  /// Usuário Firebase atual
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// Stream de mudanças no estado de autenticação
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Realiza login com email e senha
  Future<Result<firebase_auth.User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return Result.error(
          Exception('Erro ao fazer login: usuário não encontrado'),
        );
      }

      return Result.ok(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.error(_handleAuthException(e));
    } catch (e) {
      return Result.error(Exception('Erro inesperado ao fazer login: $e'));
    }
  }

  /// Envia email de recuperação de senha
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.ok(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.error(_handleAuthException(e));
    } catch (e) {
      return Result.error(Exception('Erro ao enviar email de recuperação: $e'));
    }
  }

  /// Realiza logout
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao fazer logout: $e'));
    }
  }

  /// Verifica se o email do usuário está verificado
  bool get isEmailVerified => currentFirebaseUser?.emailVerified ?? false;

  /// Envia email de verificação
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        return Result.error(Exception('Nenhum usuário autenticado'));
      }

      await user.sendEmailVerification();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao enviar email de verificação: $e'));
    }
  }

  /// Atualiza o perfil do usuário (nome e foto)
  Future<Result<void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        return Result.error(Exception('Nenhum usuário autenticado'));
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await user.reload();

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao atualizar perfil: $e'));
    }
  }

  /// Recarrega os dados do usuário atual
  Future<Result<void>> reloadUser() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        return Result.error(Exception('Nenhum usuário autenticado'));
      }

      await user.reload();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao recarregar usuário: $e'));
    }
  }

  /// Manipula exceções do Firebase Auth e retorna mensagens amigáveis
  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Usuário não encontrado');
      case 'wrong-password':
        return Exception('Senha incorreta');
      case 'invalid-email':
        return Exception('Email inválido');
      case 'user-disabled':
        return Exception('Usuário desabilitado');
      case 'too-many-requests':
        return Exception('Muitas tentativas. Tente novamente mais tarde');
      case 'network-request-failed':
        return Exception('Erro de conexão. Verifique sua internet');
      case 'invalid-credential':
        return Exception('Credenciais inválidas');
      case 'email-already-in-use':
        return Exception('Este email já está em uso');
      case 'weak-password':
        return Exception('Senha muito fraca');
      case 'operation-not-allowed':
        return Exception('Operação não permitida');
      default:
        return Exception('Erro de autenticação: ${e.message}');
    }
  }
}
