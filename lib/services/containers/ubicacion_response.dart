import 'package:segadi/models/containers/area.dart';
import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/models/containers/espacio.dart';
import 'package:segadi/models/containers/nivel.dart';

class UbicacionesResponse {
  final List<Area> areas;
  final List<Espacio> espacios;
  final List<Nivel> niveles;
  final List<Ubicacion> ubicaciones;

  UbicacionesResponse({
    required this.areas,
    required this.espacios,
    required this.niveles,
    required this.ubicaciones,
  });

  factory UbicacionesResponse.fromJson(Map<String, dynamic> json) {
    return UbicacionesResponse(
      areas: (json['areas'] as List)
          .map((areaJson) => Area.fromJson(areaJson))
          .toList(),
      espacios: (json['espacios'] as List)
          .map((espacioJson) => Espacio.fromJson(espacioJson))
          .toList(),
      niveles: (json['niveles'] as List)
          .map((nivelJson) => Nivel.fromJson(nivelJson))
          .toList(),
      ubicaciones: (json['ubicaciones'] as List)
          .map((ubicacionJson) => Ubicacion.fromJson(ubicacionJson))
          .toList(),
    );
  }
}
