import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/model/login/biometric_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segadi/model/login/user_login.dart';

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
    token = await storage.read(key: 'auth_token');
    if (token != null) {
      await storage.delete(key: 'token');
    }
    username = await storage.read(key: 'username');
    password = await storage.read(key: 'password');

    _isAuthenticated = await _biometricModel.authenticateWithBiometrics();

    if (_isAuthenticated == true && username != null && password != null) {
      String? decodedUsername = utf8.decode(base64.decode(username!));
      String? decodedPassword = utf8.decode(base64.decode(password!));

      http.Response response =
          await _authService.login(decodedUsername, decodedPassword);

      if (response.statusCode == 200) {
        Map responseMap = json.decode(response.body);
        await storage.write(key: 'token', value: responseMap['token']);

        _isAuthenticatedWithToken = true;
      }
    }
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    token = await storage.read(key: 'auth_token');
    notifyListeners();
  }
}
