import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para armazenamento local com SharedPreferences
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUser = 'user';

  /// Salva o token de autenticação
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(_keyAuthToken, token);
  }

  /// Obtém o token de autenticação
  String? getAuthToken() {
    return _prefs.getString(_keyAuthToken);
  }

  /// Remove o token de autenticação
  Future<void> removeAuthToken() async {
    await _prefs.remove(_keyAuthToken);
  }

  /// Salva os dados do usuário
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_keyUser, jsonEncode(user));
  }

  /// Obtém os dados do usuário
  Map<String, dynamic>? getUser() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  /// Remove os dados do usuário
  Future<void> removeUser() async {
    await _prefs.remove(_keyUser);
  }

  /// Limpa todos os dados armazenados
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  /// Verifica se o usuário está autenticado
  bool isAuthenticated() {
    return getAuthToken() != null;
  }
}
