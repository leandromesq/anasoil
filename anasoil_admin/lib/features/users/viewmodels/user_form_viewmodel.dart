import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/services/auth_service.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class UserFormViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  UserModel? _editingUser;
  UserModel? get editingUser => _editingUser;

  late final fetchUserCommand = Command1(_fetchUser);
  late final saveUserCommand = Command1(_saveUser);

  UserFormViewModel(this._firestoreService, this._authService);

  AsyncResult<Unit> _fetchUser(String userId) async {
    final user = await _firestoreService.getUserById(userId).first;
    _editingUser = user;
    notifyListeners();
    return Success(unit);
  }

  AsyncResult<Unit> _saveUser(UserModel user) async {
    try {
      if (user.id.isEmpty) {
        // Cria o usuário no Firebase Auth primeiro para obter o UID
        final uid = await _authService.createAuthUser(user.email);
        await _firestoreService.addUser(uid, user);
      } else {
        await _firestoreService.updateUser(user.id, user);
      }
      return Success(unit);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }
}
