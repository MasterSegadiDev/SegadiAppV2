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
        debugPrint('FCM: onTokenRefresh se ejecutó');
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

  @visibleForTesting
  Future<void> simulateTokenRefresh(String token) async {
    await _handleTokenRefresh(token);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> testTokenRegeneration() async {
    try {
      debugPrint('FCM TEST: iniciando regeneración');

      final newToken = await firebaseService.regenerateToken();

      if (newToken == null || newToken.isEmpty) {
        debugPrint('FCM TEST: no se obtuvo un nuevo token');
        return;
      }

      final hasSession = await SessionManager.hasSession();

      if (!hasSession) {
        debugPrint('FCM TEST: no existe sesión');
        return;
      }

      // Registrar explícitamente el nuevo token.
      // No dependemos de que onTokenRefresh se dispare.
      await repository.registerToken(newToken);

      debugPrint(
        'FCM TEST: nuevo token registrado en backend',
      );
    } catch (e) {
      debugPrint('FCM TEST: error: $e');
    }
  }
}
