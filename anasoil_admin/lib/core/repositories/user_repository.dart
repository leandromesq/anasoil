import 'dart:async';

import 'package:anasoil_admin/core/auth/user_auth_gateway.dart';
import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:anasoil_admin/core/services/admin_session.dart';
import 'package:anasoil_admin/core/stores/user_store.dart';
import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';

/// Admin user-management module.
///
/// Owns the user-management workflow seen by ViewModels: create/update users,
/// activate/deactivate users, and manage farmer/consultant relations. Firebase
/// details stay behind [UserAuthGateway] and [UserStore].
class UserRepository extends ChangeNotifier {
  final UserStore _userStore;
  final UserAuthGateway _authGateway;
  final AdminSession _session;

  UserRepository(this._userStore, this._authGateway, this._session);

  List<UserModel> _users = [];
  StreamSubscription<List<UserModel>>? _usersSubscription;

  List<UserModel> get users => List.unmodifiable(_users);

  Future<List<UserModel>> getUsers() async {
    final firstEmission = Completer<List<UserModel>>();

    await _usersSubscription?.cancel();
    _usersSubscription = _userStore.getUsers().listen(
      (users) {
        _users = users;
        notifyListeners();
        if (!firstEmission.isCompleted) {
          firstEmission.complete(_users);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!firstEmission.isCompleted) {
          firstEmission.completeError(error, stackTrace);
        }
      },
    );

    return firstEmission.future;
  }

  Future<UserModel?> getUser(String userId) {
    return _userStore.getUser(userId);
  }

  Future<UserModel?> getUserById(String userId) {
    return _userStore.getUserById(userId).first;
  }

  Future<UserModel?> getUserByEmail(String email) {
    return _userStore.getUserByEmail(email);
  }

  Future<List<UserModel>> getAllUsers() async {
    _users = await _userStore.getAllUsers();
    notifyListeners();
    return _users;
  }

  Future<void> saveUser(UserModel user) async {
    _session.ensureCanManageData();

    final normalizedUser = user.copyWith(email: _normalizeEmail(user.email));

    if (normalizedUser.id.isEmpty) {
      await _ensureEmailIsAvailable(normalizedUser.email);
      final uid = await _authGateway.createAuthUser(normalizedUser.email);
      await _userStore.addUser(uid, normalizedUser);
    } else {
      await _ensureEmailIsAvailable(
        normalizedUser.email,
        excludeUserId: normalizedUser.id,
      );
      await _ensureCanSaveRoleChange(normalizedUser);
      await _userStore.updateUser(normalizedUser.id, normalizedUser);
    }

    await getUsers();
  }

  Future<void> deleteUser(String userId) async {
    _session.ensureCanManageData();

    await _ensureCanDeactivateUser(userId);
    await _userStore.deleteUser(userId);
    await getUsers();
  }

  Future<void> updateUserStatus(String userId, bool active) async {
    _session.ensureCanManageData();

    if (!active) {
      await _ensureCanDeactivateUser(userId);
    }

    await _userStore.updateUserStatus(userId, active);
    await getUsers();
  }

  Future<void> linkFarmerToConsultant(
    String farmerId,
    String consultantId,
  ) async {
    _session.ensureCanManageRelations(consultantId: consultantId);

    final farmer = await _userStore.getUser(farmerId);
    final consultant = await _userStore.getUser(consultantId);
    _ensureRelationRoles(farmer, consultant);

    await _userStore.linkFarmerToConsultant(farmerId, consultantId);
    await getAllUsers();
  }

  Future<void> unlinkFarmerFromConsultant(
    String farmerId,
    String consultantId,
  ) async {
    _session.ensureCanManageRelations(consultantId: consultantId);

    final farmer = await _userStore.getUser(farmerId);
    final consultant = await _userStore.getUser(consultantId);
    _ensureRelationRoles(farmer, consultant);

    await _userStore.unlinkFarmerFromConsultant(farmerId, consultantId);
    await getAllUsers();
  }

  Future<List<UserModel>> getLinkedConsultants(UserModel farmer) async {
    final allUsers = await getAllUsers();
    return allUsers
        .where(
          (user) =>
              user.userRole == UserRole.consultant &&
              farmer.consultorIds.contains(user.id) &&
              _isRelationConsultantVisibleToCurrentUser(user.id),
        )
        .toList();
  }

  Future<List<UserModel>> getLinkedFarmers(UserModel consultant) async {
    if (!_isRelationConsultantVisibleToCurrentUser(consultant.id)) {
      return [];
    }

    final allUsers = await getAllUsers();
    return allUsers
        .where(
          (user) =>
              user.userRole == UserRole.farmer &&
              consultant.agricultorIds.contains(user.id),
        )
        .toList();
  }

  Future<List<UserModel>> getAvailableConsultants(UserModel farmer) async {
    final allUsers = await getAllUsers();
    return allUsers
        .where(
          (user) =>
              user.userRole == UserRole.consultant &&
              user.active &&
              !farmer.consultorIds.contains(user.id) &&
              _isRelationConsultantVisibleToCurrentUser(user.id),
        )
        .toList();
  }

  Future<List<UserModel>> getAvailableFarmers(UserModel consultant) async {
    if (!_isRelationConsultantVisibleToCurrentUser(consultant.id)) {
      return [];
    }

    final allUsers = await getAllUsers();
    return allUsers
        .where(
          (user) =>
              user.userRole == UserRole.farmer &&
              user.active &&
              !consultant.agricultorIds.contains(user.id),
        )
        .toList();
  }

  void clearUsers() {
    _users = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _ensureEmailIsAvailable(
    String email, {
    String? excludeUserId,
  }) async {
    final exists = await _userStore.emailExists(
      email,
      excludeUserId: excludeUserId,
    );
    if (exists) {
      throw Exception('Este email já está em uso por outro usuário.');
    }
  }

  Future<void> _ensureCanSaveRoleChange(UserModel nextUser) async {
    final current = await _userStore.getUser(nextUser.id);
    if (current == null) return;

    final removesLastAdminRole =
        current.userRole == UserRole.admin &&
        nextUser.userRole != UserRole.admin &&
        await _activeAdminCount() <= 1;

    if (removesLastAdminRole) {
      throw Exception(
        'Não é possível remover o papel do último administrador ativo.',
      );
    }
  }

  Future<void> _ensureCanDeactivateUser(String userId) async {
    if (_authGateway.currentUserId == userId) {
      throw Exception('Não é possível desativar o próprio usuário.');
    }

    final user = await _userStore.getUser(userId);
    if (user == null) {
      throw Exception('Usuário não encontrado.');
    }

    if (user.userRole == UserRole.admin && await _activeAdminCount() <= 1) {
      throw Exception('Não é possível desativar o último administrador ativo.');
    }
  }

  void _ensureRelationRoles(UserModel? farmer, UserModel? consultant) {
    if (farmer == null || consultant == null) {
      throw Exception('Usuário (agricultor ou consultor) não encontrado.');
    }
    if (!farmer.active || !consultant.active) {
      throw Exception('Não é possível vincular usuários inativos.');
    }
    if (farmer.userRole != UserRole.farmer ||
        consultant.userRole != UserRole.consultant) {
      throw Exception('Vínculo deve ser entre Agricultor e Consultor.');
    }
  }

  bool _isRelationConsultantVisibleToCurrentUser(String consultantId) {
    if (_session.currentUserRole != UserRole.consultant) return true;
    return _session.currentUserProfile?.id == consultantId;
  }

  Future<int> _activeAdminCount() async {
    final users = await _userStore.getAllUsers();
    return users
        .where((user) => user.userRole == UserRole.admin && user.active)
        .length;
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
}
