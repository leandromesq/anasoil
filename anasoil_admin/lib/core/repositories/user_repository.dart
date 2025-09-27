import 'package:anasoil_admin/core/models/user_model.dart';
import 'package:flutter/material.dart';

class UserRepository extends ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  void setUsers(List<UserModel> userList) {
    _users = userList;
    notifyListeners();
  }

  void clearUsers() {
    _users = [];
    notifyListeners();
  }
}
