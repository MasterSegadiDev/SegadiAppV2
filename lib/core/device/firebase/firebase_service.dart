abstract class FirebaseService {
  Future<String?> getToken();

  Stream<String> get onTokenRefresh;
}
