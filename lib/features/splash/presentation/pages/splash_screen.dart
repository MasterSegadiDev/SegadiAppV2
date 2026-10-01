import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segadi/features/local_service/presentation/providers/provider.dart';

import '../../../../core/security/permission_codes.dart';
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
      // ==============================================
      // VALIDAR SESIÓN
      // ==============================================

      final hasSession = await SessionManager.hasSession();

      if (!hasSession) {
        if (!mounted) return;

        context.go('/login');
        return;
      }

      // ==============================================
      // RESTAURAR USUARIO
      // ==============================================

      await ref.read(currentUserProvider.notifier).loadUser();

      final user = ref.read(currentUserProvider);

      if (user == null) {
        await SessionManager.clearSession();

        if (!mounted) return;

        context.go('/login');
        return;
      }

      // ==============================================
      // FUTURO:
      // REFRESH TOKEN
      // ==============================================

      // if (await SessionManager.shouldRefreshToken()) {
      //   await refreshToken();
      // }

      // ==============================================
      // CONSULTAR SERVICIOS LOCALES
      // ==============================================
      //
      // El usuario ya fue restaurado.
      //
      // Si tiene permiso de Servicios,
      // consultamos si tiene un tramo activo.
      // ==============================================

      final hasServicesPermission = user.permissions.contains(
        PermissionCodes.viewServices,
      );

      if (hasServicesPermission) {
        await ref.read(tramoProvider.notifier).load();
      } else {
        ref.read(tramoProvider.notifier).clear();
      }

      // ==============================================
      // IR AL HOME
      // ==============================================

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      debugPrint(
        'Error inicializando aplicación: $e',
      );

      ref.read(tramoProvider.notifier).clear();

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
