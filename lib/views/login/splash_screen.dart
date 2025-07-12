import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Simula carga
    await Future.delayed(const Duration(seconds: 1));

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home_page');
    } else {
      // Antes de navegar, resetea el estado del LoginViewModel para evitar el loading eterno
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
