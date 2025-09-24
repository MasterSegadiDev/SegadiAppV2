import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:segadi/models/login/user_login.dart';
import 'package:segadi/repo/device_info_respository.dart';
import 'package:segadi/services/getDataDevice.dart';
import 'package:segadi/utils/user_session.dart';
import 'package:segadi/viewmodels/devices/device_view_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DeviceInfoViewModel _deviceInfoViewModel =
      DeviceInfoViewModel(DeviceInfoRespository(), InfoDeviceSystemERP());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _deviceError;
  String? get deviceError => _deviceError;

  bool _isValidScreen = false;
  bool get isValidScreen => _isValidScreen;

  String _username = '';
  String _password = '';

  String? _token;
  String? get token => _token;

  // Setters para campos que notifican a la UI
  set username(String value) {
    _username = value.trim();
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  LoginViewModel() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('username') ?? '';
    username = savedUser;
    usernameController.text = savedUser;
  }

  Future<void> login() async {
    _setLoading(true);
    _clearErrors();

    if (_username.isEmpty || _password.isEmpty) {
      _setError('Usuario y contraseña son obligatorios.');
      _setLoading(false);
      return;
    }

    try {
      final response = await _authService.login(_username, _password);

      if (response.statusCode != 200 || response.body.isEmpty) {
        throw Exception('Error al iniciar sesión. Inténtalo nuevamente.');
      }

      final data = json.decode(response.body);
      print('data login: $data');
      if (data['token'] == null) {
        throw Exception('No tienes acceso a la aplicación móvil.');
      }

      _token = data['token'];

      await _clearUserData();
      await _saveUserData(data);

      await _validateDevice();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
      _clearForm(); // Opcional: quitar si deseas mantener campos tras error
    }
  }

  // Future<void> _saveUserData(Map data) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final user = data['user'];

  //   await prefs.setInt('id', user['id']);
  //   await prefs.setString('name', user['name']);
  //   await prefs.setString('username', _username);
  //   await prefs.setString('password', _password);
  //   await prefs.setString('token', data['token']);
  //   await prefs.setString('user_roll', user['empleado_permisionario']);
  //   await prefs.setString('user_rol_app', user['user_rol_app']);
  //   await prefs.setString('number_employe', user['employee_number']);

  //   await UserSession().loadFromPrefs();
  // }

  Future<void> _saveUserData(Map data) async {
    final prefs = await SharedPreferences.getInstance();
    final user = data['user'];

    await prefs.setInt('id', user['id']);
    await prefs.setString('name', user['name']);
    await prefs.setString('username', _username);
    await prefs.setString('password', _password);
    await prefs.setString('token', data['token']);
    await prefs.setString(
        'empleado_permisionario', user['empleado_permisionario'] ?? '');
    await prefs.setString('user_rol_app', user['user_rol_app'] ?? '');
    await prefs.setString('number_employe', user['employee_number']);
    await prefs.setString('site_id', user['site_id'] ?? '');

    await UserSession().loadFromPrefs();
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    UserSession().clear(); // ya no lleva await
  }

  Future<void> removeAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    UserSession().clear();
  }

  Future<void> _validateDevice() async {
    final result = await _deviceInfoViewModel.validateDeviceInfo();

    // result: [msg, isValid, null/null, null/null]
    final String msg = result[0];
    final bool isValid = result[1];

    if (msg.isNotEmpty && !isValid) {
      _deviceError = msg;
      _isValidScreen = false;
    } else {
      _deviceError = null;
      _isValidScreen = true;
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearErrors() {
    _errorMessage = null;
    _deviceError = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearForm() {
    _username = '';
    _password = '';
    usernameController.clear();
    passwordController.clear();
  }

  void resetState() {
    _setLoading(false);
    _clearErrors();
    _token = null;
    _isValidScreen = false;
    _clearForm();
  }

  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
