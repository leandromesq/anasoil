import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  /// Cria um usuário no Firebase Auth via REST API, sem afetar a sessão do admin.
  /// Retorna o UID do novo usuário e envia email de redefinição de senha.
  Future<String> createAuthUser(String email) async {
    final apiKey = Firebase.app().options.apiKey;
    final tempPassword = _generateTempPassword();

    final response = await http.post(
      Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': tempPassword,
        'returnSecureToken': false,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['error']['message'] as String;
      throw Exception(_mapAuthApiError(error));
    }

    final uid = jsonDecode(response.body)['localId'] as String;

    // Envia email para o usuário definir sua própria senha
    await _auth.sendPasswordResetEmail(email: email);

    return uid;
  }

  String _mapAuthApiError(String error) {
    if (error.contains('EMAIL_EXISTS')) {
      return 'Este email já possui uma conta no sistema.';
    }
    if (error.contains('INVALID_EMAIL')) {
      return 'Email inválido.';
    }
    if (error.contains('WEAK_PASSWORD')) {
      return 'Erro interno ao gerar senha temporária.';
    }
    return 'Erro ao criar conta: $error';
  }

  String _generateTempPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    return List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
