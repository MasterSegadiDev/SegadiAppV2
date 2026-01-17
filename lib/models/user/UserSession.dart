import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { operador, operadorGrua, guardiaSeguridad, desconocido }

class UserSession {
  int id = 0;
  String name = '';
  String username = '';
  String password = '';
  String token = '';
  String employeeNumber = '';
  String siteId = '';
  UserRole role = UserRole.desconocido;

  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id') ?? 0;
    name = prefs.getString('name') ?? '';
    username = prefs.getString('username') ?? '';
    password = prefs.getString('password') ?? '';
    token = prefs.getString('token') ?? '';
    employeeNumber = prefs.getString('number_employe') ?? '';
    role = _parseRole(prefs.getString('user_rol_app') ?? '');
    siteId = prefs.getString('site_id') ?? '';
  }

  Future<void> updateSiteId(String newSiteId) async {
    final prefs = await SharedPreferences.getInstance();
    siteId = newSiteId;
    await prefs.setString('site_id', newSiteId);
  }

  UserRole _parseRole(String value) {
    switch (value.toLowerCase()) {
      case 'operador':
        return UserRole.operador;
      case 'operador_grua':
        return UserRole.operadorGrua;
      case 'guardia_seguridad':
        return UserRole.guardiaSeguridad;
      default:
        return UserRole.desconocido;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
