import 'package:flutter/material.dart';

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
              onPressed: null,
              child: const Text('Cerrar Sesión'),
            )
          ],
        ),
      ),
    );
  }
}
