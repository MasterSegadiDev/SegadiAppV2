import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Listener foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('App abierta desde notificación');
      final data = message.data;

      if (data['type'] == 'REMISION_UPDATED') {
        final remisionId = data['remision_id'];
        print('🔄 Remisión actualizada: $remisionId');
        // aquí llamas a tu API
      }
    });

    // App abierta desde notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;

      if (data['type'] == 'REMISION_UPDATED') {
        final remisionId = data['remision_id'];
        print('🔄 Remisión abierta desde push: $remisionId');
      }
    });
  }

  static Future<String?> getDeviceToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
