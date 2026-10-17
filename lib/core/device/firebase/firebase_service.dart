import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FirebaseService {
  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Future<NotificationSettings> requestPermission();

  Stream<RemoteMessage> get onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage();
}
