import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_update_model.dart';

class FcmDatasource {
  final _controller = StreamController<ServiceUpdateModel>.broadcast();
  Stream<ServiceUpdateModel> get stream => _controller.stream;

  void init() {
    // 1. App en Primer Plano (Foreground) - Lo que ya tenías
    FirebaseMessaging.onMessage.listen((message) {
      _handleDataMessage(message);
    });

    // 2. App en Segundo Plano (Background) - Detecta el CLICK en la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message);
    });

    // 3. App Cerrada (Terminated) - Maneja el click si la app se abre desde cero
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });
  }

  void _handleDataMessage(RemoteMessage message) {
    debugPrint('📩 FCM message received: ${message.data}');
    if (message.data['type'] == 'SERVICIO_UPDATED') {
      final model = ServiceUpdateModel.fromMap(message.data);
      _controller.add(model);
    }
  }

  Future<void> _handleNotificationClick(RemoteMessage message) async {
    debugPrint('🖱️ Click detectado en notificación');

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      debugPrint('🚫 Usuario no logueado. Redirigiendo a Login.');
      // Si no hay sesión, lo mandamos al login para que no vea una pantalla vacía
      //NavigationService.instance.navigateTo('/login');
      return;
    }

    // Estos son los nombres que vienen de tu código en Yii2
    final String? screen = message.data['screen'];
    final String? serviceIdStr = message.data['service_id'];

    // Validamos el "screen" que definiste en el payload de Yii2
    if (screen == 'DETALLE_REMISION' && serviceIdStr != null) {
      final int? id = int.tryParse(serviceIdStr);

      if (id != null) {
        debugPrint('🚀 Navegando a: /detail_service_finished con ID: $id');

        // IMPORTANTE: El nombre de la ruta debe ser idéntico al del main.dart
        // NavigationService.instance.navigateTo(
        //   '/detail_service_finished',
        //   arguments: id,
        // );
      }
    }
  }
}
