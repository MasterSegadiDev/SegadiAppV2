import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/core/constants/app_enviroment.dart';

import 'core/constants/app_config.dart';

void main() {
  AppConfig.initialize(
    Environment
        .development, // cambiar a produccion cuando se haga el despliegue final
  );

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [],
      child: const MyApp(),
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
      routerConfig: null,
      debugShowCheckedModeBanner: false,
      title: 'Segadi Driver App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(
          0xFF2C522A,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(
            0xFF2C522A,
          ),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
