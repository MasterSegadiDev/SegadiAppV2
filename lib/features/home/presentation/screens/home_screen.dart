import 'package:flutter/material.dart';
import 'package:segadi/core/security/session_manager.dart';

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
                await SessionManager.instance.clearSession();
              },
              child: const Text('Cerrar Sesión'),
            )
          ],
        ),
      ),
    );
  }
}
