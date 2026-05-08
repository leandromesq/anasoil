import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:flutter/material.dart';

class UserRepository extends ChangeNotifier {
  final FirestoreService _firestoreService;

  UserRepository(this._firestoreService);

  List<UserModel> _users = [];
  List<UserModel> get users => List.unmodifiable(_users);

  Future<List<UserModel>> getUsers() async {
    _users = await _firestoreService.getUsers().first;
    notifyListeners();
    return _users;
  }

  Future<void> deleteUser(String userId) async {
    final canDelete = await _firestoreService.canDeleteUser(userId);
    if (!canDelete) {
      throw Exception('Não é possível excluir este usuário.');
    }

    await _firestoreService.deleteUser(userId);
    await getUsers();
  }

  Future<void> updateUserStatus(String userId, bool active) async {
    await _firestoreService.updateUserStatus(userId, active);
    await getUsers();
  }

  void clearUsers() {
    _users = [];
    notifyListeners();
  }
}
