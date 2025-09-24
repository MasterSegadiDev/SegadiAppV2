import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/viewmodels/login/user_login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula splash

    await UserSession().loadFromPrefs();
    final token = UserSession().token;

    if (token.isNotEmpty) {
      // Redirigir según el rol del usuario
      switch (UserSession().role) {
        case UserRole.operador:
          Navigator.pushReplacementNamed(context, '/home_page');
          break;
        case UserRole.operadorGrua:
          Navigator.pushReplacementNamed(context, '/services');
          break;
        case UserRole.guardiaSeguridad:
          Navigator.pushReplacementNamed(context, '/container_map');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/login');
          break;
      }
    } else {
      // Si no hay token, ir al login y limpiar estado
      final loginViewModel =
          Provider.of<LoginViewModel>(context, listen: false);
      loginViewModel.resetState();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
