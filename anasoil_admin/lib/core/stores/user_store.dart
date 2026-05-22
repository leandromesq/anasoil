import 'package:anasoil_admin/core/models/user_model.dart';

abstract class UserStore {
  Stream<List<UserModel>> getUsers();
  Stream<UserModel?> getUserById(String userId);
  Future<UserModel?> getUserByEmail(String email);
  Future<void> addUser(String uid, UserModel user);
  Future<void> updateUser(String userId, UserModel user);
  Future<void> updateUserStatus(String userId, bool active);
  Future<void> deleteUser(String userId);
  Future<bool> emailExists(String email, {String? excludeUserId});
  Future<void> linkFarmerToConsultant(String farmerId, String consultantId);
  Future<void> unlinkFarmerFromConsultant(String farmerId, String consultantId);
  Future<UserModel?> getUser(String userId);
  Future<List<UserModel>> getAllUsers();
}
