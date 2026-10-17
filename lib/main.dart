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

import 'package:segadi/firebase_options.dart';

import 'core/constants/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Ambiente
  AppConfig.initialize(
    Environment.development,
  );

  // 3. Dependencias generales
  await setupDependencies();

  getIt<FcmTokenSyncService>().start();

  // 4. Navegación de notificaciones
  final navigationHandler = NotificationNavigationHandler();

  // 5. Registrar coordinador
  setupNotificationCoordinatorDependencies(
    onNotificationTap: navigationHandler.handle,
  );

  // 6. Inicializar coordinador
  final notificationCoordinator = getIt<NotificationCoordinator>();

  await notificationCoordinator.initialize();

  // 7. Iniciar aplicación
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  // 8. Revisar si la app se abrió desde una notificación
  await notificationCoordinator.handleInitialMessage();
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
