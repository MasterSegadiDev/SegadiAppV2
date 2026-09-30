class AppRouteTitles {
  AppRouteTitles._();

  static const Map<String, String> _titles = {
    '/home': 'Inicio',
    '/services': 'Servicios asignados',
  };

  static String forPath(String path) {
    return _titles[path] ?? '';
  }
}
