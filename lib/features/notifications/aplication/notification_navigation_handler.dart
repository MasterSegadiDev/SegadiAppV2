import 'package:flutter/foundation.dart';

import 'package:segadi/features/notifications/domain/entities/push_notification_event.dart';

class NotificationNavigationHandler {
  PushNotificationEvent? _pendingEvent;

  void handle(PushNotificationEvent event) {
    _pendingEvent = event;

    debugPrint(
      'Notificación presionada: '
      '${event.type} - ${event.referralId}',
    );

    // TODO:
    // 1. Comprobar que existe una sesión válida.
    // 2. Obtener los datos de la remisión por su ID.
    // 3. Construir ServiceDetailArguments.
    // 4. Navegar mediante GoRouter.
  }

  PushNotificationEvent? takePendingEvent() {
    final event = _pendingEvent;
    _pendingEvent = null;
    return event;
  }
}
