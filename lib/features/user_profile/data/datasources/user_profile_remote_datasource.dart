abstract class UserProfileRemoteDatasource {
  Future<Map<String, dynamic>> getUserProfile({
    required String userId,
  });
}
