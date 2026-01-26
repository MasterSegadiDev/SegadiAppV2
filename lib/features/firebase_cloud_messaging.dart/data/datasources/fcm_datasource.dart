import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/service_update_model.dart';

class FcmDatasource {
  final _controller = StreamController<ServiceUpdateModel>.broadcast();

  Stream<ServiceUpdateModel> get stream => _controller.stream;

  void init() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📩 FCM message received');
      debugPrint('📦 Data: ${message.data}');

      if (message.data['type'] == 'SERVICIO_UPDATED') {
        final model = ServiceUpdateModel.fromMap(message.data);

        debugPrint('✅ Parsed ServicioUpdateModel: '
            'id=${model.servicioId}, estado=${model.nuevoEstado}');

        _controller.add(model);
      }
    });
  }
}
