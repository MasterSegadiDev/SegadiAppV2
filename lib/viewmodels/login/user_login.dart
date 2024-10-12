// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/models/login/user_login.dart';
import 'package:segadi/repo/device_info_respository.dart';
import 'package:segadi/services/getDataDevice.dart';
import 'package:segadi/viewmodels/devices/device_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DeviceInfoViewModel _deviceInfoViewModel =
      DeviceInfoViewModel(DeviceInfoRespository(), InfoDeviceSystemERP());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String name = '';

  LoginViewModel() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name') ?? '';
    notifyListeners();
  }

  Future<void> removeAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  String _username = '';
  String _password = '';

  String token = '';

  bool _isLoading = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _errorMessageDeviceUser;
  String? get errorMessageDeviceUser => _errorMessageDeviceUser;

  String get username => _username;
  String get password => _password;
  bool get isLoading => _isLoading;

  bool _isValidScreen = false;
  bool get isValidScreen => _isValidScreen;

  late var _device_on_system = null;
  get device_on_system => _device_on_system;

  late var _device_on_system_app = null;
  get device_on_system_app => _device_on_system_app;

  set username(String value) {
    _username = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  Future<void> login() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    if (_username.isEmpty) {
      _isLoading = false;

      _errorMessage = 'El campo usuario es requerido ';
    } else if (_password.isEmpty) {
      _isLoading = false;

      _errorMessage = 'El campo password es requerido ';
    } else if (_username.isNotEmpty && _password.isNotEmpty) {
      http.Response response = await _authService.login(_username, _password);

      if (response.body.isNotEmpty) {
        _errorMessage = null;

        var array = await _deviceInfoViewModel.validateDeviceInfo();
        print(array[0]);

        if (array[0] != '' && array[1] == false && array[2] == null) {
          //valida que el dispositivo no este en el sistema
          _errorMessageDeviceUser = array[0] as String?;
          _isValidScreen = false;
          _device_on_system = true;
          print('esta en on device in system null');
        } else if (array[0] != '' && array[1] == false && array[3] == null) {
          //valida que el dispositivo no este en el sistema
          _errorMessageDeviceUser = array[0] as String?;
          _isValidScreen = false;
          _device_on_system_app = true;

          print('esta en on device in app null');
        }
        final prefs = await SharedPreferences.getInstance();

        Map responseMap = json.decode(response.body);
        if (responseMap['token'] == null) {
          _isLoading = false;
          _errorMessage = 'No tienes acceso a la aplicacion movil';
        }
        if (responseMap['token'] != null) {
          _isLoading = false;
          prefs.clear();

          prefs.setInt('id', responseMap["user"]['id']);
          prefs.setString('name', responseMap["user"]['name']);
          prefs.setString('username', _username);
          prefs.setString('password', _password);
          prefs.setString('token', responseMap['token']);
          prefs.setString(
              'user_roll', responseMap['user']['empleado_permisionario']);
          print(responseMap['token']);
        }
      } else {
        _errorMessage = 'Ha ocurrido un error al logearte, intentalo de nuevo';
      }

      _username = '';
      _password = '';
      usernameController.clear();
      passwordController.clear();
    }
    notifyListeners();
  }
}
