import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SEGADI',
        ),
      ),
      drawer: const AppDrawer(),
      body: child,
    );
  }
}
