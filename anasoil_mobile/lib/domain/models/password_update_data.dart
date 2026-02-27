/// Dados para alteração de senha
class PasswordUpdateData {
  final String currentPassword;
  final String newPassword;

  const PasswordUpdateData({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }
}
