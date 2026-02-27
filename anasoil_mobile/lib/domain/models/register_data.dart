import 'profile_type.dart';

/// Dados para registro de novo usuário
class RegisterData {
  final String name;
  final String email;
  final ProfileType profileType;
  final String password;
  final String? phone;

  const RegisterData({
    required this.name,
    required this.email,
    required this.profileType,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'profileType': profileType.name,
      'password': password,
      'phone': phone,
    };
  }
}
