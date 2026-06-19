import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/core/constants/app_enviroment.dart';
import 'package:segadi/app/router/app_router.dart';

import 'core/constants/app_config.dart';

Future<void> main() async {
  AppConfig.initialize(
    Environment.development,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'Segadi Driver App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(
          0xFF2C522A,
        ),
      ),
    );
  }
}
