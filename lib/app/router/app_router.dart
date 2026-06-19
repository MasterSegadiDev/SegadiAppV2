import 'package:go_router/go_router.dart';
import 'package:segadi/features/auth/presentation/screens/login_screen.dart';
import 'package:segadi/features/auth/presentation/screens/splash_screen.dart';
import 'package:segadi/features/home/presentation/screens/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
