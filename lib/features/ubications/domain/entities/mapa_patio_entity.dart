import 'package:segadi/features/ubications/domain/entities/ubicacion_entity.dart';

class MapaPatioEntity {
  final List<String> areas;
  final List<int> espacios;
  final List<int> niveles;
  final List<UbicacionEntity> ubicaciones;

  const MapaPatioEntity({
    required this.areas,
    required this.espacios,
    required this.niveles,
    required this.ubicaciones,
  });

  // =========================
  // HELPERS
  // =========================

  List<UbicacionEntity> obtenerEspacio(
    String area,
    int espacio,
  ) {
    final lista = ubicaciones.where((u) {
      return u.area == area && u.espacio == espacio;
    }).toList();

    lista.sort((a, b) => a.nivel.compareTo(b.nivel));

    return lista;
  }

  UbicacionEntity? buscarUbicacion({
    required String area,
    required int espacio,
    required int nivel,
  }) {
    try {
      return ubicaciones.firstWhere(
        (u) => u.area == area && u.espacio == espacio && u.nivel == nivel,
      );
    } catch (_) {
      return null;
    }
  }
}
