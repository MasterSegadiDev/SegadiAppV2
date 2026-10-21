import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'package:segadi/app/router/app_routes.dart';
import 'package:segadi/core/security/session_manager.dart';

import '../domain/entities/push_notification_event.dart';
import 'referral_notification_resolver.dart';

class NotificationNavigationHandler {
  final GoRouter router;
  final ReferralNotificationResolver resolver;

  PushNotificationEvent? _pendingEvent;
  bool _isProcessing = false;
  bool _isDisposed = false;

  NotificationNavigationHandler({
    required this.router,
    required this.resolver,
  }) {
    // Detecta cuando Splash o Login terminan de navegar.
    router.routerDelegate.addListener(_onRouteChanged);
  }

  Future<void> handle(PushNotificationEvent event) async {
    debugPrint('========== NOTIFICACIÓN TOCADA ==========');
    debugPrint('TIPO: ${event.type}');
    debugPrint('REMISIÓN: ${event.referralId}');
    debugPrint(
      'RUTA ACTUAL: ${router.routerDelegate.currentConfiguration.uri.path}',
    );
    if (_isDisposed) return;

    debugPrint(
      'FCM: notificación recibida para remisión ${event.referralId}',
    );

    _pendingEvent = event;

    await _processPending();
  }

  void _onRouteChanged() {
    if (_isDisposed || _pendingEvent == null) return;

    _processPending();
  }

  bool get _isReady {
    final path = router.routerDelegate.currentConfiguration.uri.path;

    // No navegar mientras Splash restaura la sesión.
    return path != '/' && path != '/login';
  }

  Future<void> _processPending() async {
    if (_isDisposed || _isProcessing || !_isReady) return;

    _isProcessing = true;

    try {
      final hasSession = await SessionManager.hasSession();

      if (!hasSession || !_isReady) {
        return;
      }

      final event = _pendingEvent;

      if (event == null) return;

      final arguments = await resolver.resolve(event.referralId);

      if (arguments == null) {
        debugPrint(
          'FCM: remisión ${event.referralId} no encontrada',
        );
        _pendingEvent = null;
        return;
      }

      if (_isDisposed || !_isReady) return;

      if (identical(_pendingEvent, event)) {
        _pendingEvent = null;
      }

      router.push(
        AppRoutes.serviceDetail,
        extra: arguments,
      );

      debugPrint(
        'FCM: detalle abierto para ${event.referralId}',
      );
    } catch (error, stackTrace) {
      debugPrint('FCM: error navegando: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isProcessing = false;

      if (!_isDisposed && _pendingEvent != null && _isReady) {}
    }
  }

  void dispose() {
    _isDisposed = true;
    router.routerDelegate.removeListener(_onRouteChanged);
  }
}
