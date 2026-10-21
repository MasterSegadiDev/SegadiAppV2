import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_service.dart';

class FirebaseServiceImpl implements FirebaseService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  Future<String?> getToken() {
    return _messaging.getToken();
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  @override
  Future<String?> regenerateToken() async {
    await FirebaseMessaging.instance.deleteToken();

    return FirebaseMessaging.instance.getToken();
  }
}
