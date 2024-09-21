import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/model/login/biometric_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segadi/model/login/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricViewModel extends ChangeNotifier {
  final BiometricModel _biometricModel = BiometricModel();
  final storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  bool _isBiometricAvailable = false;
  bool _isAuthenticated = false;
  bool _isAuthenticatedWithToken = false;

  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isAuthenticated => _isAuthenticated;
  bool get isAuthenticatedWithToken => _isAuthenticatedWithToken;

  String? token;
  String? username;
  String? password;

  BiometricViewModel() {
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
    print('token guardado: ${token}');

    username = prefs.getString('username');
    password = await prefs.getString('password');

    if (token != null) {
      prefs.remove('token');
    }

    print('usuario ${username} and password ${password}');

    _isAuthenticated = await _biometricModel.authenticateWithBiometrics();

    if (_isAuthenticated == true && username != null && password != null) {
      http.Response response = await _authService.login(username!, password!);
      print(response.statusCode);

      if (response.statusCode == 200) {
        Map responseMap = json.decode(response.body);
        prefs.setString('token', responseMap['token']);
        _isAuthenticatedWithToken = true;

        print('nuevo token: ${prefs.getString('token')}');
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
