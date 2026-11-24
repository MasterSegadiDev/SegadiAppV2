import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'segadi_channel',
    'SEGADI Notifications',
    description: 'Notificaciones de servicios',
    importance: Importance.max,
  );

  @override
  Future<void> initialize({
    void Function(String? payload)? onNotificationTap,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: android,
    );

    // En esta versión, 'settings' ahora es un parámetro con nombre obligatorio
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationTap?.call(response.payload);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  @override
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    // En esta versión, 'id' se pasa como parámetro con nombre obligatorio
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'segadi_channel',
          'SEGADI Notifications',
          channelDescription: 'Notificaciones de servicios',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: payload,
    );
  }
}
