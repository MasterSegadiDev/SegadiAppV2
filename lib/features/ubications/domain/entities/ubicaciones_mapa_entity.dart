import 'package:segadi/features/ubications/domain/entities/ubicacion_entity.dart';

class AreaEntity {
  final String id;
  final String areaContenedor;

  AreaEntity({
    required this.id,
    required this.areaContenedor,
  });

  factory AreaEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return AreaEntity(
      id: json['id']?.toString() ?? '',
      areaContenedor: json['area_contenedor']?.toString() ?? '',
    );
  }
}

class EspacioEntity {
  final int id;
  final int espacioContenedor;

  EspacioEntity({
    required this.id,
    required this.espacioContenedor,
  });

  factory EspacioEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return EspacioEntity(
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

class NivelEntity {
  final int id;
  final int nivelContenedor;

  NivelEntity({
    required this.id,
    required this.nivelContenedor,
  });

  factory NivelEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return NivelEntity(
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

class UbicacionesMapEntity {
  final List<AreaEntity> areas;
  final List<EspacioEntity> espacios;
  final List<NivelEntity> niveles;
  final List<UbicacionEntity> ubicaciones;

  UbicacionesMapEntity({
    required this.areas,
    required this.espacios,
    required this.niveles,
    required this.ubicaciones,
  });

  factory UbicacionesMapEntity.fromJson(
    Map<String, dynamic> json,
  ) {
    return UbicacionesMapEntity(
      areas: (json['areas'] as List? ?? [])
          .map(
            (e) => AreaEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      espacios: (json['espacios'] as List? ?? [])
          .map(
            (e) => EspacioEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      niveles: (json['niveles'] as List? ?? [])
          .map(
            (e) => NivelEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      ubicaciones: (json['ubicaciones'] as List? ?? [])
          .map(
            (e) => UbicacionEntity.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
    );
  }
}
