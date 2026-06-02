import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';

import '../../domain/entities/ubicacion_entity.dart';

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
  AreaModel({
    required super.id,
    required super.areaContenedor,
  });

  factory AreaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AreaModel(
      id: json['id']?.toString() ?? '',
      areaContenedor: json['area_contenedor']?.toString() ?? '',
    );
  }
}

class EspacioModel extends EspacioEntity {
  EspacioModel({
    required super.id,
    required super.espacioContenedor,
  });

  factory EspacioModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EspacioModel(
      id: int.tryParse(
            json['id'].toString(),
          ) ??
          0,
      espacioContenedor: int.tryParse(
            json['espacio_contenedor'].toString(),
          ) ??
          0,
    );
  }
}

class NivelModel extends NivelEntity {
  NivelModel({
    required super.id,
    required super.nivelContenedor,
  });

  factory NivelModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NivelModel(
      id: int.tryParse(
            json['id'].toString(),
          ) ??
          0,
      nivelContenedor: int.tryParse(
            json['nivel_contenedor'].toString(),
          ) ??
          0,
    );
  }
}

class UbicacionModel extends UbicacionEntity {
  UbicacionModel({
    required super.id,
    required super.codigo,
    required super.area,
    required super.espacio,
    required super.nivel,
    required super.estado,
    required super.serie,
    required super.color,
  });

  factory UbicacionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UbicacionModel(
      id: json['id']?.toString() ?? '',
      codigo: json['ubicacion_contenedor']?.toString() ?? '',
      area: json['area_contenedor']?.toString() ?? '',
      espacio: int.tryParse(
            json['espacio_contenedor'].toString(),
          ) ??
          0,
      nivel: int.tryParse(
            json['nivel_contenedor'].toString(),
          ) ??
          0,
      estado: json['estatus']?.toString() ?? 'Free',
      serie: json['container_number']?.toString(),
      color: json['color']?.toString() ?? 'green',
    );
  }
}
