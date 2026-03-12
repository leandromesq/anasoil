import 'dart:developer';

import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/services/firestore_service.dart';
import 'package:anasoil_admin/core/utils/command.dart';
import 'package:anasoil_admin/core/utils/result.dart';
import 'package:flutter/material.dart';

class UserRelationViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<UserModel> linkedConsultors = [];
  List<UserModel> linkedAgricultors = [];
  List<UserModel> _allUsers = [];
  String? _currentUserId;

  late final fetchUserCommand = Command1(_fetchUser);
  late final fetchAllUsersCommand = Command0(_fetchAllUsers);
  late final linkAgricultorConsultorCommand = Command1(
    _linkAgricultorConsultor,
  );
  late final unlinkAgricultorConsultorCommand = Command1(
    _unlinkAgricultorConsultor,
  );

  UserRelationViewModel(this._firestoreService);

  Future<Result<UserModel>> _fetchUser(String userId) async {
    _currentUserId = userId;
    try {
      final user = await _firestoreService.getUser(userId);
      _allUsers = await _firestoreService.getAllUsers();

      if (user != null) {
        _updateLinkedUsers(user);
        return Result.ok(user);
      } else {
        return Result.error(Exception("Usuário não encontrado"));
      }
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  void _updateLinkedUsers(UserModel user) {
    log('All users: ${_allUsers.toString()}');
    if (user.role == 'agricultor') {
      linkedConsultors = _allUsers
          .where(
            (u) => u.role == 'consultor' && user.consultorIds.contains(u.id),
          )
          .toList();
      log('Linked consultors: ${linkedConsultors.length}');
    } else if (user.role == 'consultor') {
      linkedAgricultors = _allUsers
          .where(
            (u) => u.role == 'agricultor' && user.agricultorIds.contains(u.id),
          )
          .toList();
      log('Linked agricultors: ${linkedAgricultors.length}');
    }
    notifyListeners();
  }

  Future<Result<List<UserModel>>> _fetchAllUsers() async {
    try {
      final users = await _firestoreService.getAllUsers();
      _allUsers = users;
      return Result.ok(users);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _linkAgricultorConsultor(List<String> ids) async {
    try {
      final agricultorId = ids[0];
      final consultorId = ids[1];

      await _firestoreService.linkFarmerToConsultant(agricultorId, consultorId);

      await Future.delayed(const Duration(milliseconds: 300));

      if (_currentUserId != null) {
        await fetchUserCommand.execute(_currentUserId!);
      }

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<Result<void>> _unlinkAgricultorConsultor(List<String> ids) async {
    try {
      final agricultorId = ids[0];
      final consultorId = ids[1];

      await _firestoreService.unlinkFarmerFromConsultant(
        agricultorId,
        consultorId,
      );

      if (_currentUserId != null) {
        await fetchUserCommand.execute(_currentUserId!);
      }

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  Future<List<UserModel>> getAvailableConsultors(UserModel agricultor) async {
    var allUsers = await _firestoreService.getAllUsers();
    return allUsers
        .where(
          (user) =>
              user.role == 'consultor' &&
              user.active &&
              !agricultor.consultorIds.contains(user.id),
        )
        .toList();
  }

  Future<List<UserModel>> getAvailableAgricultors(UserModel consultor) async {
    var allUsers = await _firestoreService.getAllUsers();
    return allUsers
        .where(
          (user) =>
              user.role == 'agricultor' &&
              user.active &&
              !consultor.agricultorIds.contains(user.id),
        )
        .toList();
  }
}
