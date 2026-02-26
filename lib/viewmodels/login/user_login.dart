import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:segadi/auth/auth_service.dart';
import 'package:segadi/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:segadi/models/login/user_login.dart';
import 'package:segadi/utils/user_session.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();
  final AuthService _authService;

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

  String? _firebaseToken;
  String? get firebaseToken => _firebaseToken;

  // Setters para campos que notifican a la UI
  set username(String value) {
    _username = value.trim();
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  LoginViewModel(this._authService) {
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
      // 1. LLAMADA AL BACKEND (Lo que causaba el error)
      // Cambiamos 'http.Response' por 'final response' porque Dio devuelve un Map
      final responseData = await _authService.login(_username, _password);

      // 2. VALIDACIÓN DEL TOKEN (Tu lógica original)
      if (responseData == null || responseData['token'] == null) {
        throw Exception('No tienes acceso a la aplicación móvil.');
      }

      _token = responseData['token'];
      print('Token del sistema: $_token');

      // 🔐 FIREBASE AUTH (Tal cual lo tenías)
      final cred = await _firebaseAuth.loginWithUsername(
        username: _username,
        password: _password,
      );

      // ✅ TOKEN FCM (Tal cual lo tenías)
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        throw Exception('No se pudo obtener el token FCM del dispositivo');
      }

      print('FCM token del dispositivo: $fcmToken');

      final int userId = responseData['user']['id'];

      // 📡 ENVIAR TOKEN FCM AL BACKEND (Tu lógica original)
      await _authService.getTokenWithFirebaseBeforeLogin(
        userId,
        _token!,
        fcmToken,
      );

      // INICIALIZACIÓN DE PERMISOS FCM
      await initFCM(userId);

      // GUARDADO DE DATOS (Pasamos el responseData que es el Map)
      await _clearUserData();
      await _saveUserData(responseData); // Aquí le mandamos el mapa directo
      //await _validateDevice();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _setError('Usuario no registrado.');
      } else if (e.code == 'wrong-password') {
        _setError('Contraseña incorrecta.');
      } else {
        _setError('Error de autenticación.');
      }
    } catch (e) {
      // Manejo de errores de Dio o cualquier otra excepción
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
      // Ojo: quitamos el _clearForm() de aquí si quieres que el usuario
      // vea sus datos si algo falla, o déjalo si prefieres limpiar siempre.
    }
  }

  Future<void> initFCM(int user_id) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 Permisos FCM: ${settings.authorizationStatus} se han iniciado');

    // inicializamos el listener
    await NotificationService.init();

    //obtiene token del dispositivo
    final deviceToken = await NotificationService.getDeviceToken();

    if (deviceToken != null) {
      print('Device Token FCM: $deviceToken');
    }
  }

  Future<void> _saveUserData(Map data) async {
    final prefs = await SharedPreferences.getInstance();
    final user = data['user'];

    await prefs.setInt('id', user['id']);
    await prefs.setString('name', user['name']);
    await prefs.setString('username', _username);
    await prefs.setString('password', _password);
    await prefs.setString('token', data['token']);
    //await prefs.setString('token_firebase', data['token_firebase']);
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

  // Future<void> _validateDevice() async {
  //   final result = await _deviceInfoViewModel.validateDeviceInfo();

  //   // result: [msg, isValid, null/null, null/null]
  //   final String msg = result[0];
  //   final bool isValid = result[1];

  //   if (msg.isNotEmpty && !isValid) {
  //     _deviceError = msg;
  //     _isValidScreen = false;
  //   } else {
  //     _deviceError = null;
  //     _isValidScreen = true;
  //   }
  // }

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
