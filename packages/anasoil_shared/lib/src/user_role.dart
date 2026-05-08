/// Canonical AnaSoil user roles shared by mobile and admin.
enum UserRole {
  admin('admin', 'Administrador'),
  consultant('consultant', 'Consultor'),
  farmer('farmer', 'Agricultor');

  const UserRole(this.firestoreValue, this.displayName);

  final String firestoreValue;
  final String displayName;

  bool get canUseMobile => this == consultant || this == farmer;
  bool get canManageUsers => this == admin;
  bool get canManageRelations => this == consultant || this == farmer;

  static UserRole parse(String? value, {UserRole fallback = UserRole.farmer}) {
    final normalized = value?.trim().toLowerCase();
    switch (normalized) {
      case 'admin':
      case 'administrator':
      case 'administrador':
        return UserRole.admin;
      case 'consultant':
      case 'consultor':
        return UserRole.consultant;
      case 'farmer':
      case 'agricultor':
        return UserRole.farmer;
      default:
        return fallback;
    }
  }

  static List<UserRole> get assignable => const [admin, consultant, farmer];
}

extension UserRoleString on String {
  UserRole toUserRole({UserRole fallback = UserRole.farmer}) =>
      UserRole.parse(this, fallback: fallback);
}
