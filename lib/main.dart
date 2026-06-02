import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:segadi/core/config/app_enviroment.dart';
import 'package:segadi/core/config/env.dart';

import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/core/router/app_router.dart';
import 'package:segadi/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:segadi/features/auth/data/datasources/auth_remote_datasource.dart';

import 'package:segadi/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:segadi/features/auth/domain/use_cases/login_use_case.dart';

import 'package:segadi/features/auth/presentation/providers/auth_provider.dart';
import 'package:segadi/features/auth/presentation/view_models/login_view_model.dart';

void main() {
  Env.environment = Environment.dev;

  WidgetsFlutterBinding.ensureInitialized();

  final dioClient = DioClient();
  const secureStorage = FlutterSecureStorage();
  final authRemoteDatasource = AuthRemoteDatasource(
      //dioClient.dio,
      );

  final authLocalDatasource = AuthLocalDatasource(
    secureStorage,
  );

  /// REPOSITORY
  final authRepository = AuthRepositoryImpl(
    remoteDatasource: authRemoteDatasource,
    localDatasource: authLocalDatasource,
  );

  /// USE CASES
  final loginUseCase = LoginUseCase(
    authRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        /// AUTH GLOBAL STATE
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authRepository,
          ),
        ),

        /// LOGIN VIEWMODEL
        ChangeNotifierProxyProvider<AuthProvider, LoginViewModel>(
          create: (_) => LoginViewModel(
            loginUseCase: loginUseCase,
          ),
          update: (
            _,
            authProvider,
            loginViewModel,
          ) {
            if (loginViewModel == null) {
              throw Exception(
                'LoginViewModel no inicializado',
              );
            }

            loginViewModel.setAuthProvider(
              authProvider,
            );

            return loginViewModel;
          },
        ),
      ],
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
    final authProvider = context.watch<AuthProvider>();

    final appRouter = AppRouter(authProvider).router;

    return MaterialApp.router(
      routerConfig: appRouter,
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
