class AppRouteTitles {
  AppRouteTitles._();

  static const Map<String, String> _titles = {
    '/home': 'Inicio',
    '/services': 'Servicios asignados',
    '/local-service': 'Servicios Locales Por Tramo',
    '/evidence/eir': 'Enviar Envidencia Entrega Contenedor',
  };

  static String forPath(String path) {
    return _titles[path] ?? '';
  }
}
