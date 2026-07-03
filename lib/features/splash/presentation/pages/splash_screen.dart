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
    _loadSession();
  }

  Future<void> _loadSession() async {
    final token = await SessionManager.getAccessToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      context.go('/login');
      return;
    }

    context.go('/home');
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
