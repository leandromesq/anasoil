import 'package:flutter/foundation.dart';
import '../../../domain/models/user_profile.dart';
import '../../../domain/models/profile_update_data.dart';
import '../../../domain/models/password_update_data.dart';
import '../../../utils/result.dart';
import 'dart:io';

/// Interface do repositório de perfil do usuário
abstract class ProfileRepository extends ChangeNotifier {
  /// Perfil do usuário atual
  UserProfile? get profile;

  /// Carrega o perfil completo do usuário
  Future<Result<UserProfile>> getProfile();

  /// Atualiza dados do perfil
  Future<Result<UserProfile>> updateProfile(ProfileUpdateData data);

  /// Altera a senha do usuário
  Future<Result<void>> updatePassword(PasswordUpdateData data);

  /// Atualiza a foto de perfil
  Future<Result<UserProfile>> updateAvatar(File imageFile);

  /// Remove a foto de perfil
  Future<Result<UserProfile>> removeAvatar();

  /// Exclui a conta do usuário
  Future<Result<void>> deleteAccount(String password);
}
