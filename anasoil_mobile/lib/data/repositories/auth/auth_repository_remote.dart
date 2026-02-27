import '../../../domain/models/user.dart';
import '../../../domain/models/login_credentials.dart';
import '../../../domain/models/register_data.dart';
import '../../../utils/result.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import 'auth_repository.dart';

/// Implementação remota do repositório de autenticação usando Firebase
class AuthRepositoryRemote extends AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final StorageService _storage;

  User? _currentUser;

  AuthRepositoryRemote({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
    required StorageService storage,
  }) : _authService = authService,
       _firestoreService = firestoreService,
       _storage = storage {
    _initializeUser();
  }

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  /// Inicializa o usuário do storage ao instanciar o repository
  Future<void> _initializeUser() async {
    // Verifica se há usuário autenticado no Firebase Auth
    final firebaseUser = _authService.currentFirebaseUser;

    if (firebaseUser != null && firebaseUser.email != null) {
      // Busca os dados do usuário no Firestore por email
      final result = await _firestoreService.getUserByEmail(
        firebaseUser.email!,
      );

      if (result is Ok<User?>) {
        final user = result.value;
        if (user != null) {
          _currentUser = user;
          await _storage.saveUser(user.toJson());
          notifyListeners();
        }
      }
    } else {
      // Tenta carregar do storage local
      final userJson = _storage.getUser();
      if (userJson != null) {
        _currentUser = User.fromJson(userJson);
        notifyListeners();
      }
    }
  }

  @override
  Future<Result<User>> login(LoginCredentials credentials) async {
    try {
      // Faz login no Firebase Auth
      final authResult = await _authService.signInWithEmailAndPassword(
        email: credentials.email,
        password: credentials.password,
      );

      if (authResult is Error) {
        return Result.error((authResult as Error).error);
      }

      final firebaseUser = (authResult as Ok).value;

      if (firebaseUser.email == null) {
        await _authService.signOut();
        return Result.error(
          Exception('Email não encontrado no usuário autenticado'),
        );
      }

      // Busca dados do usuário no Firestore por email
      final userResult = await _firestoreService.getUserByEmail(
        firebaseUser.email!,
      );

      if (userResult is Error) {
        await _authService.signOut();
        return Result.error((userResult as Error<User?>).error);
      }

      final user = (userResult as Ok<User?>).value;

      if (user == null) {
        await _authService.signOut();
        return Result.error(Exception('Usuário não encontrado no sistema'));
      }

      // Verifica se o usuário está ativo
      final activeResult = await _firestoreService.isUserActive(user.id);
      if (activeResult is Ok<bool>) {
        if (!activeResult.value) {
          await _authService.signOut();
          return Result.error(
            Exception('Usuário inativo. Entre em contato com o administrador'),
          );
        }
      }

      // Salva usuário no storage local
      await _storage.saveUser(user.toJson());
      _currentUser = user;
      notifyListeners();

      return Result.ok(user);
    } catch (e) {
      return Result.error(Exception('Erro ao fazer login: $e'));
    }
  }

  @override
  Future<Result<User>> register(RegisterData data) async {
    // Registro não é permitido pelo app móvel
    return Result.error(
      Exception(
        'Cadastro não disponível. Entre em contato com o administrador',
      ),
    );
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      return await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      return Result.error(Exception('Erro ao recuperar senha: $e'));
    }
  }

  @override
  Future<Result<User?>> loadCurrentUser() async {
    try {
      final firebaseUser = _authService.currentFirebaseUser;

      if (firebaseUser == null || firebaseUser.email == null) {
        await _clearAuthData();
        return Result.ok(null);
      }

      // Atualiza dados do Firestore por email
      final result = await _firestoreService.getUserByEmail(
        firebaseUser.email!,
      );

      if (result is Error) {
        return Result.error((result as Error).error);
      }

      final user = (result as Ok<User?>).value;

      if (user == null) {
        await _clearAuthData();
        return Result.ok(null);
      }

      await _storage.saveUser(user.toJson());
      _currentUser = user;
      notifyListeners();

      return Result.ok(user);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar usuário: $e'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _authService.signOut();
      await _clearAuthData();
      return Result.ok(null);
    } catch (e) {
      // Mesmo com erro, limpar dados locais
      await _clearAuthData();
      return Result.ok(null);
    }
  }

  /// Limpa todos os dados de autenticação
  Future<void> _clearAuthData() async {
    await _storage.removeUser();
    _currentUser = null;
    notifyListeners();
  }
}
