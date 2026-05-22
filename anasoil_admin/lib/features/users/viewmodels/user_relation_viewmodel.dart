import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/repositories/user_repository.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';

class UserRelationViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  List<UserModel> linkedConsultors = [];
  List<UserModel> linkedAgricultors = [];
  String? _currentUserId;

  late final fetchUserCommand = Command1(_fetchUser);
  late final fetchAllUsersCommand = Command0(_fetchAllUsers);
  late final linkAgricultorConsultorCommand = Command1(
    _linkAgricultorConsultor,
  );
  late final unlinkAgricultorConsultorCommand = Command1(
    _unlinkAgricultorConsultor,
  );

  UserRelationViewModel(this._userRepository);

  Future<Result<UserModel>> _fetchUser(String userId) async {
    _currentUserId = userId;
    try {
      final user = await _userRepository.getUser(userId);

      if (user == null) {
        return Result.error(Exception('Usuário não encontrado'));
      }

      await _updateLinkedUsers(user);
      return Result.ok(user);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<void> _updateLinkedUsers(UserModel user) async {
    if (user.userRole == UserRole.farmer) {
      linkedConsultors = await _userRepository.getLinkedConsultants(user);
      linkedAgricultors = [];
    } else if (user.userRole == UserRole.consultant) {
      linkedAgricultors = await _userRepository.getLinkedFarmers(user);
      linkedConsultors = [];
    } else {
      linkedConsultors = [];
      linkedAgricultors = [];
    }
    notifyListeners();
  }

  Future<Result<List<UserModel>>> _fetchAllUsers() async {
    try {
      final users = await _userRepository.getAllUsers();
      return Result.ok(users);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _linkAgricultorConsultor(List<String> ids) async {
    try {
      final agricultorId = ids[0];
      final consultorId = ids[1];

      await _userRepository.linkFarmerToConsultant(agricultorId, consultorId);
      await _refreshCurrentUser();

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _unlinkAgricultorConsultor(List<String> ids) async {
    try {
      final agricultorId = ids[0];
      final consultorId = ids[1];

      await _userRepository.unlinkFarmerFromConsultant(
        agricultorId,
        consultorId,
      );
      await _refreshCurrentUser();

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<void> _refreshCurrentUser() async {
    if (_currentUserId != null) {
      await fetchUserCommand.execute(_currentUserId!);
    }
  }

  Future<List<UserModel>> getAvailableConsultors(UserModel agricultor) {
    return _userRepository.getAvailableConsultants(agricultor);
  }

  Future<List<UserModel>> getAvailableAgricultors(UserModel consultor) {
    return _userRepository.getAvailableFarmers(consultor);
  }
}
