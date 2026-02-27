/// Credenciais para login
class LoginCredentials {
  final String email;
  final String password;

  const LoginCredentials({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
