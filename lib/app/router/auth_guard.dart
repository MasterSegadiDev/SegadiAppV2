import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/current_user_provider.dart';

class AuthGuard {
  final Ref ref;

  AuthGuard(
    this.ref,
  );

  String? redirect(
    BuildContext context,
    GoRouterState state,
  ) {
    final location = state.matchedLocation;

    // Permitir Splash siempre
    if (location == '/') {
      return null;
    }

    final user = ref.read(
      currentUserProvider,
    );

    final isLoggedIn = user != null;

    final isGoingToLogin = location == '/login';

    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }

    if (isLoggedIn && isGoingToLogin) {
      return '/home';
    }

    return null;
  }
}
