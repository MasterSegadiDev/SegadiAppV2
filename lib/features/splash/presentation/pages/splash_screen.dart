import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/session_manager.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      /// ¿Existe sesión?
      final hasSession = await SessionManager.hasSession();

      if (!hasSession) {
        if (!mounted) return;

        context.go('/login');
        return;
      }

      /// Restaurar usuario
      await ref.read(currentUserProvider.notifier).loadUser();

      /// Validar que realmente exista el usuario
      final user = ref.read(currentUserProvider);

      if (user == null) {
        await SessionManager.clearSession();

        if (!mounted) return;

        context.go('/login');
        return;
      }

      /// Aquí después agregaremos:
      ///
      /// if(await SessionManager.shouldRefreshToken()){
      ///      refreshToken();
      /// }

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      debugPrint(e.toString());

      await SessionManager.clearSession();

      if (!mounted) return;

      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
