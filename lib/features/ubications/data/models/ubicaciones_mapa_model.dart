import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';

class InventarioMapaModel extends UbicacionesMapEntity {
  InventarioMapaModel({
    required super.areas,
    required super.espacios,
    required super.niveles,
    required super.ubicaciones,
  });

  factory InventarioMapaModel.fromJson(Map<String, dynamic> json) {
    return InventarioMapaModel(
      // Usamos los Models en lugar de las Entities para que se ejecute el mapeo de abajo
      areas: (json['areas'] as List? ?? [])
          .map((e) => AreaModel.fromJson(e)) // Cambiado a AreaModel
          .toList(),
      espacios: (json['espacios'] as List? ?? [])
          .map((e) => EspacioModel.fromJson(e)) // Cambiado a EspacioModel
          .toList(),
      niveles: (json['niveles'] as List? ?? [])
          .map((e) => NivelModel.fromJson(e)) // Cambiado a NivelModel
          .toList(),
      ubicaciones: (json['ubicaciones'] as List? ?? [])
          .map((e) => UbicacionModel.fromJson(e)) // Cambiado a UbicacionModel
          .toList(),
    );
  }
}

class AreaModel extends AreaEntity {
  AreaModel({required super.id, required super.nombre});
  factory AreaModel.fromJson(Map<String, dynamic> json) => AreaModel(
      id: json['id']?.toString() ?? '',
      nombre: json['area_contenedor']?.toString() ?? '');
}

class EspacioModel extends EspacioEntity {
  EspacioModel({required super.id, required super.nombre});
  factory EspacioModel.fromJson(Map<String, dynamic> json) => EspacioModel(
      id: json['id']?.toString() ?? '',
      nombre: json['espacio_contenedor']?.toString() ?? '');
}

class NivelModel extends NivelEntity {
  NivelModel({required super.id, required super.nombre});
  factory NivelModel.fromJson(Map<String, dynamic> json) => NivelModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nivel_contenedor']?.toString() ?? '');
}

class UbicacionModel extends UbicacionEntity {
  UbicacionModel({
    required super.id,
    required super.codigo,
    required super.area,
    required super.espacio,
    required super.nivel,
    required super.estatus,
    super.serie,
    required super.color,
  });

  factory UbicacionModel.fromJson(Map<String, dynamic> json) {
    return UbicacionModel(
      id: json['id']?.toString() ?? '',
      codigo: json['ubicacion_contenedor']?.toString() ?? '',
      area: json['area_contenedor']?.toString() ?? '',
      espacio: json['espacio_contenedor']?.toString() ??
          '', // <--- Clave para tu cuadrícula
      nivel: json['nivel_contenedor']?.toString() ?? '',
      estatus: json['estatus']?.toString() ?? 'Free',
      serie: json['container_number']?.toString(), // Puede ser null
      color: json['color']?.toString() ?? 'green',
    );
  }
}
