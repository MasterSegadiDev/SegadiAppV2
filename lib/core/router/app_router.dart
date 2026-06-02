import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:segadi/features/auth/presentation/providers/auth_provider.dart';
import 'package:segadi/features/auth/presentation/screens/login_screen.dart';
import 'package:segadi/features/auth/presentation/view_models/login_view_model.dart';
import 'package:segadi/features/home/presentation/screens/home_screen.dart';
import 'package:segadi/features/ubications/presentation/screens/movimiento_list_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    refreshListenable:
        authProvider, // GoRouter se reconstruye cuando el AuthProvider cambia
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
          path: '/containers',
          builder: (context, state) => const MovimientoView()),
      // Vista rápida de acceso denegado integrada para evitar crear otro archivo
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_bad, size: 70, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Acceso No Autorizado',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    'No tienes los permisos necesarios para este módulo.'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Volver'),
                )
              ],
            ),
          ),
        ),
      ),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final status = authProvider.authStatus;

      if (status == AuthStatus.checking) return null;

      // 1. Si no está logueado y no está en login, mándalo a login
      if (status == AuthStatus.notAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // 2. Si está logueado, validamos los accesos por rol
      if (status == AuthStatus.authenticated) {
        // Obtenemos el rol actual guardado en el LoginViewModel
        final loginVm = context.read<LoginViewModel>();
        final role = loginVm.currentRole;

        // Si está en login o splash, lo mandamos a su pantalla correspondiente por defecto
        if (isLoggingIn || state.matchedLocation == '/splash') {
          return (role == 'OPERADOR_GRUA') ? '/containers' : '/home';
        }

        // --- CANDADOS DE SEGURIDAD PARA RUTAS ---

        // Bloqueo: Si es Operador de Grúa e intenta entrar al Home de Tráiler
        if (state.matchedLocation == '/home' && role == 'OPERADOR_GRUA') {
          return '/unauthorized';
        }

        // Bloqueo: Si es Operador de Tráiler e intenta entrar a Contenedores
        if (state.matchedLocation == '/containers' &&
            role == 'OPERADOR_TRAILER') {
          return '/unauthorized';
        }
      }

      return null;
    },
  );
}
