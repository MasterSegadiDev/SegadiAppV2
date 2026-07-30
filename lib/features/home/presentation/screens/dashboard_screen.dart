import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  ConsumerState<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Center(
        child: Text(
          'Usuario no encontrado',
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bienvenido ${user.name}',
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Rol: ${user.roles.join(", ")}',
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Permisos:',
          ),
          ...user.permissions.map(
            (permission) => Text(permission),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();

              if (!mounted) return;

              context.go('/login');
            },
            child: const Text(
              'Cerrar Sesión',
            ),
          ),
        ],
      ),
    );
  }
}
