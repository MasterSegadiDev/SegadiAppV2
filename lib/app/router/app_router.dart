import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/features/splash/presentation/pages/splash_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import 'auth_guard.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    final guard = AuthGuard(ref);

    return GoRouter(
      initialLocation: '/',
      redirect: guard.redirect,
      routes: [
        GoRoute(
          path: '/',
          builder: (
            context,
            state,
          ) =>
              const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (
            context,
            state,
          ) =>
              const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (
            context,
            state,
          ) =>
              const HomeScreen(),
        ),
      ],
    );
  },
);
