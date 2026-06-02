import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenido Chofer'),
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
              },
              child: const Text('Cerrar Sesión'),
            )
          ],
        ),
      ),
    );
  }
}
