import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/utils/command.dart';
import 'package:anasoil_admin/core/utils/result.dart';
import 'package:flutter/material.dart';

class UserFormViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserModel? _editingUser;
  UserModel? get editingUser => _editingUser;

  late final fetchUserCommand = Command1(_fetchUser);
  late final saveUserCommand = Command1(_saveUser);

  UserFormViewModel(this._userRepository);

  Future<Result<void>> _fetchUser(String userId) async {
    try {
      final user = await _userRepository.getUserById(userId);
      _editingUser = user;
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _saveUser(UserModel user) async {
    try {
      await _userRepository.saveUser(user);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }
}
