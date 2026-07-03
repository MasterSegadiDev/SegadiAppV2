import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection_container.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';

import 'package:segadi/core/contracts/network_info.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final networkInfo = getIt<NetworkInfo>();

    final connected = await networkInfo.isConnected;

    print('¿Hay internet?: $connected');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuario no encontrado'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido ${user.name}'),
            const SizedBox(height: 10),
            Text('Rol: ${user.roles.join(", ")}'),
            const SizedBox(height: 10),
            const Text('Permisos:'),
            ...user.permissions.map(
              (p) => Text(p),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();

                if (!mounted) return;

                context.go('/login');
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
