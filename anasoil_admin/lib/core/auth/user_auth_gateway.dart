abstract class UserAuthGateway {
  String? get currentUserId;

  Future<String> createAuthUser(String email);
}
