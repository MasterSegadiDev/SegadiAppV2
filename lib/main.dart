import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/core/constants/app_enviroment.dart';
import 'package:segadi/core/router/app_router.dart';

import 'core/constants/app_config.dart';

void main() {
  AppConfig.initialize(
    Environment
        .development, // cambiar a produccion cuando se haga el despliegue final
  );

  WidgetsFlutterBinding.ensureInitialized();

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
