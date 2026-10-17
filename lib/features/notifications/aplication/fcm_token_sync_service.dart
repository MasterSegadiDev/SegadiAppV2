import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:segadi/core/security/session_manager.dart';
import 'package:segadi/features/notifications/domain/repositories/fcm_token_repository.dart';

// Ajusta este import a la ruta real de FirebaseService.
import 'package:segadi/core/device/firebase/firebase_service.dart';

class FcmTokenSyncService {
  final FirebaseService firebaseService;
  final FcmTokenRepository repository;

  StreamSubscription<String>? _subscription;

  FcmTokenSyncService({
    required this.firebaseService,
    required this.repository,
  });

  void start() {
    // Evitar múltiples suscripciones.
    if (_subscription != null) return;

    _subscription = firebaseService.onTokenRefresh.listen(
      (token) async {
        await _handleTokenRefresh(token);
      },
      onError: (Object error) {
        debugPrint(
          'FCM: error escuchando renovación del token: $error',
        );
      },
    );

    debugPrint('FCM: listener de renovación iniciado');
  }

  Future<void> _handleTokenRefresh(String token) async {
    try {
      if (token.trim().isEmpty) {
        return;
      }

      // Verificar que exista una sesión.
      final hasSession = await SessionManager.hasSession();

      if (!hasSession) {
        debugPrint(
          'FCM: no existe sesión, se omite registro',
        );
        return;
      }

      // Registrar nuevo token en el backend.
      await repository.registerToken(token);

      debugPrint(
        'FCM: token renovado y registrado correctamente',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'FCM: error al registrar token renovado: $e',
      );

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
