import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  int? id;
  String? name;
  String? username;
  String? token;
  String? password;
  String? userRoll;
  String? userRollApp;
  String? numberEmployee;
  String? siteId;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id');
    name = prefs.getString('name');
    username = prefs.getString('username');
    password = prefs.getString('password');
    token = prefs.getString('token');
    userRoll = prefs.getString('empleado_permisionario');
    userRollApp = prefs.getString('user_rol_app');
    numberEmployee = prefs.getString('number_employe');
    siteId = prefs.getString('site_id');
  }

  void clear() {
    id = null;
    name = null;
    username = null;
    password = null;
    token = null;
    userRoll = null;
    userRollApp = null;
    numberEmployee = null;
    siteId = null;
  }
}
