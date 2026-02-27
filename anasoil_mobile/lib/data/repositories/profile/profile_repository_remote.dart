import 'dart:io';
import '../../../domain/models/user_profile.dart';
import '../../../domain/models/profile_update_data.dart';
import '../../../domain/models/password_update_data.dart';
import '../../../utils/result.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import 'profile_repository.dart';

/// Implementação do repositório de perfil usando Firebase
class ProfileRepositoryRemote extends ProfileRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final StorageService _storage;

  UserProfile? _profile;

  ProfileRepositoryRemote({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
    required StorageService storage,
  }) : _authService = authService,
       _firestoreService = firestoreService,
       _storage = storage;

  @override
  UserProfile? get profile => _profile;

  @override
  Future<Result<UserProfile>> getProfile() async {
    try {
      final firebaseUser = _authService.currentFirebaseUser;

      if (firebaseUser == null || firebaseUser.email == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      // Busca perfil do Firestore por email
      final userResult = await _firestoreService.getUserByEmail(
        firebaseUser.email!,
      );

      if (userResult is Error) {
        return Result.error((userResult as Error).error);
      }

      final user = (userResult as Ok).value;

      if (user == null) {
        return Result.error(Exception('Perfil não encontrado'));
      }

      // Converte User para UserProfile
      _profile = UserProfile(
        id: user.id,
        name: user.name,
        email: user.email,
        profileType: user.profileType,
        phone: user.phone,
        avatarUrl: null, // TODO: Implementar storage de imagens
        createdAt: DateTime.now(), // TODO: Pegar do Firestore
      );

      notifyListeners();
      return Result.ok(_profile!);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar perfil: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(ProfileUpdateData data) async {
    try {
      if (_profile == null) {
        return Result.error(Exception('Perfil não carregado'));
      }

      // Atualiza no Firestore
      final updateData = data.toJson();
      final result = await _firestoreService.updateUser(
        _profile!.id,
        updateData,
      );

      if (result is Error) {
        return Result.error(result.error);
      }

      // Atualiza perfil local
      _profile = _profile!.copyWith(
        name: data.name ?? _profile!.name,
        phone: data.phone ?? _profile!.phone,
        updatedAt: DateTime.now(),
      );

      // Atualiza storage local
      await _storage.saveUser(_profile!.toJson());

      notifyListeners();
      return Result.ok(_profile!);
    } catch (e) {
      return Result.error(Exception('Erro ao atualizar perfil: $e'));
    }
  }

  @override
  Future<Result<void>> updatePassword(PasswordUpdateData data) async {
    try {
      final firebaseUser = _authService.currentFirebaseUser;

      if (firebaseUser == null || firebaseUser.email == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      // Reautentica o usuário com a senha atual
      final reauthResult = await _authService.signInWithEmailAndPassword(
        email: firebaseUser.email!,
        password: data.currentPassword,
      );

      if (reauthResult is Error) {
        return Result.error(Exception('Senha atual incorreta'));
      }

      // Atualiza a senha no Firebase Auth
      try {
        await firebaseUser.updatePassword(data.newPassword);
        return Result.ok(null);
      } catch (e) {
        return Result.error(Exception('Erro ao atualizar senha: $e'));
      }
    } catch (e) {
      return Result.error(Exception('Erro ao alterar senha: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> updateAvatar(File imageFile) async {
    // TODO: Implementar upload de imagem para Firebase Storage
    return Result.error(Exception('Upload de imagem não implementado ainda'));
  }

  @override
  Future<Result<UserProfile>> removeAvatar() async {
    // TODO: Implementar remoção de imagem do Firebase Storage
    return Result.error(Exception('Remoção de imagem não implementada ainda'));
  }

  @override
  Future<Result<void>> deleteAccount(String password) async {
    try {
      final firebaseUser = _authService.currentFirebaseUser;

      if (firebaseUser == null || firebaseUser.email == null) {
        return Result.error(Exception('Usuário não autenticado'));
      }

      // Reautentica o usuário
      final reauthResult = await _authService.signInWithEmailAndPassword(
        email: firebaseUser.email!,
        password: password,
      );

      if (reauthResult is Error) {
        return Result.error(Exception('Senha incorreta'));
      }

      // Deleta dados do Firestore
      if (_profile != null) {
        await _firestoreService.updateUser(_profile!.id, {'active': false});
      }

      // Deleta conta do Firebase Auth
      await firebaseUser.delete();

      // Limpa dados locais
      await _storage.removeUser();
      _profile = null;
      notifyListeners();

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao excluir conta: $e'));
    }
  }
}
