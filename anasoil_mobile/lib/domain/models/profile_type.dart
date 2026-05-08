import 'package:anasoil_shared/anasoil_shared.dart';

/// Mobile-compatible profile type backed by the shared AnaSoil role contract.
enum ProfileType {
  /// Agricultor - Responsável pelas atividades diárias de plantio
  farmer,

  /// Consultor Agrícola - Auxilia nas decisões estratégicas
  consultant;

  String get displayName => toUserRole().displayName;

  String get firestoreValue => toUserRole().firestoreValue;

  UserRole toUserRole() {
    switch (this) {
      case ProfileType.farmer:
        return UserRole.farmer;
      case ProfileType.consultant:
        return UserRole.consultant;
    }
  }

  static ProfileType fromRole(UserRole role) {
    switch (role) {
      case UserRole.consultant:
        return ProfileType.consultant;
      case UserRole.admin:
      case UserRole.farmer:
        return ProfileType.farmer;
    }
  }
}
