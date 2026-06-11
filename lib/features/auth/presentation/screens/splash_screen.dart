import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await SessionManager.instance.getAccessToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
