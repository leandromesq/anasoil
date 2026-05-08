import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/utils/command.dart';
import 'package:anasoil_admin/core/utils/result.dart';
import 'package:flutter/material.dart';

class UserListViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  List<UserModel> get users => _userRepository.users;

  late final fetchUsersCommand = Command0(_fetchUsers);
  late final deleteUserCommand = Command1(_deleteUser);
  late final updateUserStatusCommand = Command2(_updateUserStatus);

  UserListViewModel(this._userRepository) {
    _userRepository.addListener(notifyListeners);
  }

  Future<Result<void>> _fetchUsers() async {
    try {
      await _userRepository.getUsers();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _deleteUser(String userId) async {
    try {
      await _userRepository.deleteUser(userId);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _updateUserStatus(String userId, bool active) async {
    try {
      await _userRepository.updateUserStatus(userId, active);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  @override
  void dispose() {
    _userRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
