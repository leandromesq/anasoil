import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/profile/profile_repository.dart';
import '../../../domain/models/user_profile.dart';
import '../../../domain/models/profile_update_data.dart';
import '../../../domain/models/password_update_data.dart';
import '../../../utils/command.dart';

/// ViewModel para gerenciar o perfil do usuário
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileViewModel({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository {
    // Escuta mudanças no repository
    _profileRepository.addListener(notifyListeners);

    // Inicializa commands
    loadProfileCommand = Command0(_profileRepository.getProfile);
    updateProfileCommand = Command1(_profileRepository.updateProfile);
    updatePasswordCommand = Command1(_profileRepository.updatePassword);
    updateAvatarCommand = Command1(_profileRepository.updateAvatar);
    removeAvatarCommand = Command0(_profileRepository.removeAvatar);
    deleteAccountCommand = Command1(_profileRepository.deleteAccount);
  }

  // Commands
  late final Command0<UserProfile> loadProfileCommand;
  late final Command1<UserProfile, ProfileUpdateData> updateProfileCommand;
  late final Command1<void, PasswordUpdateData> updatePasswordCommand;
  late final Command1<UserProfile, File> updateAvatarCommand;
  late final Command0<UserProfile> removeAvatarCommand;
  late final Command1<void, String> deleteAccountCommand;

  /// Perfil do usuário atual
  UserProfile? get profile => _profileRepository.profile;

  /// Verifica se o perfil está carregado
  bool get isProfileLoaded => profile != null;

  @override
  void dispose() {
    _profileRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
