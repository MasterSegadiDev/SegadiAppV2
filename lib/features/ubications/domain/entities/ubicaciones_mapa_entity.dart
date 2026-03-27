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

  factory UbicacionesMapEntity.fromJson(Map<String, dynamic> json) {
    return UbicacionesMapEntity(
      areas: (json['areas'] as List? ?? [])
          .map((e) => AreaEntity.fromJson(e))
          .toList(),
      espacios: (json['espacios'] as List? ?? [])
          .map((e) => EspacioEntity.fromJson(e))
          .toList(),
      niveles: (json['niveles'] as List? ?? [])
          .map((e) => NivelEntity.fromJson(e))
          .toList(),
      ubicaciones: (json['ubicaciones'] as List? ?? [])
          .map((e) => UbicacionEntity.fromJson(e))
          .toList(),
    );
  }
}

class AreaEntity {
  final String id;
  final String nombre;
  AreaEntity({required this.id, required this.nombre});

  factory AreaEntity.fromJson(Map<String, dynamic> json) => AreaEntity(
        id: json['id']?.toString() ?? '',
        // Nota: En tu JSON es 'area_contenedor'
        nombre: (json['area_contenedor'] ?? json['nombre'] ?? '').toString(),
      );
}

class EspacioEntity {
  final String id;
  final String nombre;
  EspacioEntity({required this.id, required this.nombre});

  factory EspacioEntity.fromJson(Map<String, dynamic> json) => EspacioEntity(
        id: json['id']?.toString() ?? '',
        // Nota: En tu JSON es 'espacio_contenedor'
        nombre: (json['espacio_contenedor'] ?? json['nombre'] ?? '').toString(),
      );
}

class NivelEntity {
  final String id;
  final String nombre;
  NivelEntity({required this.id, required this.nombre});

  factory NivelEntity.fromJson(Map<String, dynamic> json) => NivelEntity(
        id: json['id']?.toString() ?? '',
        // Nota: En tu JSON es 'nivel_contenedor'
        nombre: (json['nivel_contenedor'] ?? json['nombre'] ?? '').toString(),
      );
}

class UbicacionEntity {
  final String id;
  final String codigo;
  final String area;
  final String espacio;
  final String nivel;
  final String estatus;
  final String? serie;
  final String color;

  UbicacionEntity({
    required this.id,
    required this.codigo,
    required this.area,
    required this.espacio,
    required this.nivel,
    required this.estatus,
    this.serie,
    required this.color,
  });

  factory UbicacionEntity.fromJson(Map<String, dynamic> json) =>
      UbicacionEntity(
        id: json['id']?.toString() ?? '',
        codigo: json['ubicacion_contenedor']?.toString() ?? '',
        area: json['area_contenedor']?.toString() ?? '',
        espacio: json['espacio_contenedor']?.toString() ?? '',
        nivel: json['nivel_contenedor']?.toString() ?? '',
        estatus: json['estatus']?.toString() ?? 'Free',
        serie: json['container_number']?.toString(),
        color: json['color']?.toString() ?? 'green',
      );

  factory UbicacionEntity.empty() {
    return UbicacionEntity(
      id: "",
      area: "",
      espacio: "",
      nivel: "",
      estatus: "",
      serie: "",
      codigo: '',
      color: '',
    );
  }
}
