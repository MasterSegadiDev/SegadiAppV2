import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_service.dart';

class FirebaseServiceImpl implements FirebaseService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
