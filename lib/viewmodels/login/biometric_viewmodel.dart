import 'package:flutter/material.dart';

import 'package:segadi/models/login/biometric_model.dart';

import 'package:segadi/models/login/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricViewModel extends ChangeNotifier {
  final BiometricModel _biometricModel = BiometricModel();
  final AuthService _authService;

  bool _isBiometricAvailable = false;
  bool _isAuthenticated = false;
  bool _isAuthenticatedWithToken = false;

  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAuthenticatedWithToken => _isAuthenticatedWithToken;

  String? token;
  String? username;
  String? password;

  BiometricViewModel(this._authService) {
    checkBiometricAvailability();
    _loadFromPrefs();
  }

  Future<void> checkBiometricAvailability() async {
    _isBiometricAvailable = await _biometricModel.isBiometricAvailable();
    notifyListeners();
  }

  Future<void> authenticate() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    username = prefs.getString('username');
    password = prefs.getString('password');

    if (token != null) {
      prefs.remove('token');
    }

    _isAuthenticated = await _biometricModel.authenticateWithBiometrics();

    if (_isAuthenticated == true && username != null && password != null) {
      try {
        // 1. Aquí 'response' ya es el Map<String, dynamic> que envió el AuthService
        final responseMap = await _authService.login(username!, password!);

        // 2. Ya no pidas 'response.data', usa 'responseMap' directamente
        if (responseMap.isEmpty && responseMap['token'] != null) {
          prefs.setString('token', responseMap['token']);
          _isAuthenticatedWithToken = true;
          print('✅ Autenticación exitosa');
        }
      } catch (e) {
        _isAuthenticatedWithToken = false;
        debugPrint('❌ Error: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    notifyListeners();
  }
}
