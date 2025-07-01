import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:segadi/utils/user_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:segadi/models/login/user_login.dart';
import 'package:segadi/repo/device_info_respository.dart';
import 'package:segadi/services/getDataDevice.dart';
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

  // Token actual
  String? _token;
  String? get token => _token;

  // Setters que notifican cambios
  set username(String value) {
    _username = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  LoginViewModel() {
    _loadUserFromPrefs();
  }

  /// Cargar nombre del usuario almacenado
  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
  }

  /// Elimina todo de SharedPreferences
  Future<void> removeAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Login principal
  Future<void> login() async {
    _errorMessage = null;
    _deviceError = null;
    _isLoading = true;
    notifyListeners();

    if (_username.trim().isEmpty) {
      _setError('El campo usuario es requerido');
      return;
    }

    if (_password.trim().isEmpty) {
      _setError('El campo password es requerido');
      return;
    }

    try {
      final response = await _authService.login(_username, _password);

      if (response.statusCode != 200 || response.body.isEmpty) {
        _setError('Error al loguearte. Inténtalo de nuevo.');
        return;
      }

      final data = json.decode(response.body);

      if (data['token'] == null) {
        _setError('No tienes acceso a la aplicación móvil');
        return;
      }

      _token = data['token'];
      await _clearUserData();
      await _saveUserData(data);
      await _validateDevice();
    } catch (e) {
      _setError('Error de conexión o datos inválidos');
    } finally {
      _isLoading = false;
      _clearForm();
      notifyListeners();
    }
  }

  /// Guarda los datos del usuario autenticado
  Future<void> _saveUserData(Map data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', data['user']['id']);
    await prefs.setString('name', data['user']['name']);
    await prefs.setString('username', _username);
    await prefs.setString('password', _password);
    await prefs.setString('token', data['token']);
    await prefs.setString('user_roll', data['user']['empleado_permisionario']);
    await prefs.setString('user_rol_app', data['user']['user_rol_app']);
    await prefs.setString('number_employe', data['user']['employee_number']);

    await UserSession().loadFromPrefs();
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    UserSession().clear(); // Borra también el singleton en memoria
  }

  /// Valida información del dispositivo después de login
  Future<void> _validateDevice() async {
    final result = await _deviceInfoViewModel.validateDeviceInfo();

    if (result[0] != '' && result[1] == false && result[2] == null) {
      _deviceError = result[0];
      _isValidScreen = false;
      return;
    }

    if (result[0] != '' && result[1] == false && result[3] == null) {
      _deviceError = result[0];
      _isValidScreen = false;
      return;
    }

    _isValidScreen = true;
  }

  /// Maneja error común
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Limpia campos del formulario
  void _clearForm() {
    _username = '';
    _password = '';
    usernameController.clear();
    passwordController.clear();
  }

  /// Método para recuperar token en otras ViewModels
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
