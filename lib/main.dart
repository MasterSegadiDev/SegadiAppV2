import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/app/di/notification_coordinator_injection.dart';
import 'package:segadi/app/router/app_router.dart';

import 'package:segadi/core/constants/app_enviroment.dart';
import 'package:segadi/core/theme/app_theme.dart';
import 'package:segadi/features/notifications/aplication/fcm_token_sync_service.dart';
import 'package:segadi/features/notifications/aplication/notification_coordinator.dart';
import 'package:segadi/features/notifications/aplication/notification_navigation_handler.dart';
import 'package:segadi/features/notifications/aplication/referral_notification_resolver.dart';

import 'package:segadi/firebase_options.dart';

import 'core/constants/app_config.dart';

import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Configurar ambiente.
  AppConfig.initialize(
    Environment.development,
  );

  // 3. Registrar dependencias generales.
  await setupDependencies();

  // 4. Iniciar sincronización del token FCM.
  getIt<FcmTokenSyncService>().start();

  // 5. Registrar el resolver ANTES de obtenerlo.
  setupNotificationResolverDependencies();

  final resolver = getIt<ReferralNotificationResolver>();

  // 6. Crear un único contenedor de Riverpod.
  final container = ProviderContainer();

  // El mismo router se utilizará para toda la aplicación.
  final router = container.read(routerProvider);

  // 7. Crear el handler de navegación.
  final navigationHandler = NotificationNavigationHandler(
    router: router,
    resolver: resolver,
  );

  // 8. Registrar el coordinador de notificaciones.
  setupNotificationCoordinatorDependencies(
    onNotificationTap: (event) {
      unawaited(navigationHandler.handle(event));
    },
  );

  final notificationCoordinator = getIt<NotificationCoordinator>();

  // 9. Configurar recepción de notificaciones.
  await notificationCoordinator.initialize();

  // 10. Iniciar la app con EL MISMO contenedor.
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );

  // 11. Procesar notificación que abrió la aplicación.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(notificationCoordinator.handleInitialMessage());
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Segadi Driver App',
      routerConfig: router,
      theme: AppTheme.light,
    );
  }
}
