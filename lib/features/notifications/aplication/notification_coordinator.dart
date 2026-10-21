import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:segadi/core/device/notifications/notification_service.dart';
import 'package:segadi/features/notifications/domain/entities/push_notification_event.dart';

class NotificationCoordinator {
  final NotificationService notificationService;
  bool _initialized = false;

  final void Function(PushNotificationEvent event) onNotificationTap;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  NotificationCoordinator({
    required this.notificationService,
    required this.onNotificationTap,
  });

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    // 1. Inicializar las notificaciones locales.
    await notificationService.initialize(
      onNotificationTap: (payload) {
        debugPrint('========== NOTIFICACIÓN LOCAL TOCADA ==========');
        debugPrint('PAYLOAD: $payload');
        final event = PushNotificationEvent.fromPayload(payload);

        if (event != null) {
          onNotificationTap(event);
        }
      },
    );

    // 2. Solicitar permisos.
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'FCM permission: ${settings.authorizationStatus}',
    );

    // 3. Mensajes recibidos con la app abierta.
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // 4. El usuario abre una notificación FCM
    // desde segundo plano.
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationOpened,
    );
  }

  Future<void> handleInitialMessage() async {
    // 5. El usuario inicia la app tocando
    // una notificación FCM.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationOpened(initialMessage);
    }
  }

  Future<void> _handleForegroundMessage(
    RemoteMessage message,
  ) async {
    debugPrint('FCM recibido: ${message.data}');

    final notification = message.notification;

    if (notification == null) {
      return;
    }

    final event = PushNotificationEvent.fromData(message.data);

    try {
      await notificationService.show(
        title: notification.title ?? 'SEGADI',
        body: notification.body ?? '',
        payload: event?.toPayload(),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Error mostrando notificación local: $error',
      );

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _handleNotificationOpened(
    RemoteMessage message,
  ) {
    debugPrint('========== FCM NOTIFICACIÓN ABIERTA ==========');
    debugPrint('DATA: ${message.data}');
    final event = PushNotificationEvent.fromData(message.data);

    if (event == null) {
      debugPrint(
        'Notificación sin datos de remisión válidos',
      );
      return;
    }

    debugPrint(
      'FCM TAP: type=${event.type}, referral=${event.referralId}',
    );

    onNotificationTap(event);
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
  }
}
