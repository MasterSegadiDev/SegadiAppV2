abstract class RefreshRemoteDatasource {
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  });
}
