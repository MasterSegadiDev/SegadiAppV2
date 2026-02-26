import 'package:flutter/foundation.dart';
import 'package:segadi/models/contenedores/ubicacion.dart';

import 'package:segadi/models/contenedores/punto_movimiento.dart';
import 'package:segadi/services/contenedores/ubicaciones_service.dart';

class UbicacionesViewModel extends ChangeNotifier {
  final UbicacionesService _service;
  UbicacionesViewModel(this._service);

  List<Ubicacion> _ubicaciones = [];
  List<Ubicacion> get ubicaciones => _ubicaciones;

  bool isLoading = false;
  String? error;

  PuntoMovimiento? origen;
  PuntoMovimiento? destino;

  Future<void> cargarUbicaciones(String siteId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _ubicaciones = await _service.fetchUbicaciones(siteId: siteId);
    } catch (_) {
      _ubicaciones = [];
      error = 'Error cargando ubicaciones';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<String> getAreas() => _ubicaciones.map((u) => u.area).toSet().toList();

  List<String> getEspaciosPorArea(String area) => _ubicaciones
      .where((u) => u.area == area)
      .map((u) => u.espacio)
      .toSet()
      .toList();

  List<String> getNivelesPorEspacio(String area, String espacio) => _ubicaciones
      .where((u) => u.area == area && u.espacio == espacio)
      .map((u) => u.nivel)
      .toSet()
      .toList();

  Ubicacion? getUbicacion(String area, String espacio, String nivel) =>
      _ubicaciones.firstWhere(
          (u) => u.area == area && u.espacio == espacio && u.nivel == nivel,
          orElse: () => null as Ubicacion);

  bool esOcupado(String area, String espacio, String nivel) {
    final u = getUbicacion(area, espacio, nivel);
    return u?.numberSerie != null && u!.numberSerie!.trim().isNotEmpty;
  }

  List<Ubicacion> getUbicacionesPorAreaEspacioYNivel(
          String area, String espacio, [String? nivel]) =>
      _ubicaciones
          .where((u) =>
              u.area == area &&
              u.espacio == espacio &&
              (nivel == null || u.nivel == nivel))
          .toList();

  void resetSeleccion() {
    origen = null;
    destino = null;
    notifyListeners();
  }

  void setOrigen(PuntoMovimiento p) {
    origen = p;
    notifyListeners();
  }

  void setDestino(PuntoMovimiento p) {
    destino = p;
    notifyListeners();
  }
}
