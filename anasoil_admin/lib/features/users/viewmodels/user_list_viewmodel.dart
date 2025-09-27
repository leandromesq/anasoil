import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class UserListViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final FirestoreService _firestoreService;

  List<UserModel> get users => _userRepository.users;

  late final fetchUsersCommand = Command0(_fetchUsers);
  late final deleteUserCommand = Command1(_deleteUser);

  UserListViewModel(this._userRepository, this._firestoreService) {
    _userRepository.addListener(notifyListeners);
  }

  AsyncResult<Unit> _fetchUsers() async {
    final userList = await _firestoreService.getUsers().first;
    _userRepository.setUsers(userList);
    return Success(unit);
  }

  AsyncResult<Unit> _deleteUser(String userId) async {
    await _firestoreService.deleteUser(userId);
    await fetchUsersCommand.execute();
    return Success(unit);
  }

  @override
  void dispose() {
    _userRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
