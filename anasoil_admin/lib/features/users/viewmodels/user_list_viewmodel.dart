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
  late final updateUserStatusCommand = Command2(_updateUserStatus);

  UserListViewModel(this._userRepository, this._firestoreService) {
    _userRepository.addListener(notifyListeners);
  }

  AsyncResult<Unit> _fetchUsers() async {
    final userList = await _firestoreService.getUsers().first;
    _userRepository.setUsers(userList);
    return Success(unit);
  }

  AsyncResult<Unit> _deleteUser(String userId) async {
    try {
      // Verifica se o usuário pode ser excluído
      final canDelete = await _firestoreService.canDeleteUser(userId);
      if (!canDelete) {
        throw Exception('Não é possível excluir este usuário.');
      }

      await _firestoreService.deleteUser(userId);
      await fetchUsersCommand.execute();
      return Success(unit);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  AsyncResult<Unit> _updateUserStatus(String userId, bool active) async {
    try {
      await _firestoreService.updateUserStatus(userId, active);
      await fetchUsersCommand.execute();
      return Success(unit);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  @override
  void dispose() {
    _userRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
