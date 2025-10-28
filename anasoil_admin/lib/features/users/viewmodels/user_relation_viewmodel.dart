import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class UserRelationViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  UserModel? _currentUser;
  List<UserModel> _allUsers = [];

  UserModel? get currentUser => _currentUser;
  List<UserModel> get allUsers => _allUsers;

  late final fetchUserCommand = Command1(_fetchUser);
  late final fetchAllUsersCommand = Command0(_fetchAllUsers);
  late final linkAgricultorConsultorCommand = Command1(
    _linkAgricultorConsultor,
  );
  late final unlinkAgricultorConsultorCommand = Command1(
    _unlinkAgricultorConsultor,
  );

  UserRelationViewModel(this._firestoreService);

  AsyncResult<Unit> _fetchUser(String userId) async {
    try {
      final user = await _firestoreService.getUserById(userId).first;
      _currentUser = user;
      notifyListeners();
      return Success(unit);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  AsyncResult<Unit> _fetchAllUsers() async {
    try {
      final users = await _firestoreService.getUsers().first;
      _allUsers = users;
      notifyListeners();
      return Success(unit);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  AsyncResult<Unit> _linkAgricultorConsultor(List<String> ids) async {
    try {
      final agricultorId = ids[0];
      final consultorId = ids[1];

      await _firestoreService.linkFarmerToConsultant(agricultorId, consultorId);

      // Atualiza os dados locais
      await fetchUserCommand.execute(_currentUser!.id);
      await fetchAllUsersCommand.execute();

      return Success(unit);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  AsyncResult<Unit> _unlinkAgricultorConsultor(List<String> ids) async {
    try {
      final agricultorId = ids[0];
      final consultorId = ids[1];

      await _firestoreService.unlinkFarmerFromConsultant(
        agricultorId,
        consultorId,
      );

      // Atualiza os dados locais
      await fetchUserCommand.execute(_currentUser!.id);
      await fetchAllUsersCommand.execute();

      return Success(unit);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Retorna os consultores vinculados a um agricultor
  List<UserModel> getLinkedConsultors(UserModel agricultor) {
    return _allUsers
        .where(
          (user) =>
              user.role == 'consultor' &&
              agricultor.consultorIds.contains(user.id),
        )
        .toList();
  }

  /// Retorna os agricultores vinculados a um consultor
  List<UserModel> getLinkedAgricultors(UserModel consultor) {
    return _allUsers
        .where(
          (user) =>
              user.role == 'agricultor' &&
              consultor.agricultorIds.contains(user.id),
        )
        .toList();
  }

  /// Retorna os consultores disponíveis para vincular a um agricultor
  List<UserModel> getAvailableConsultors(UserModel agricultor) {
    return _allUsers
        .where(
          (user) =>
              user.role == 'consultor' &&
              user.active &&
              !agricultor.consultorIds.contains(user.id),
        )
        .toList();
  }

  /// Retorna os agricultores disponíveis para vincular a um consultor
  List<UserModel> getAvailableAgricultors(UserModel consultor) {
    return _allUsers
        .where(
          (user) =>
              user.role == 'agricultor' &&
              user.active &&
              !consultor.agricultorIds.contains(user.id),
        )
        .toList();
  }
}
