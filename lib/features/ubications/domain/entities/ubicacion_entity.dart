class UbicacionEntity {
  final String id;
  final String codigo;
  final String area;
  final int espacio;
  final int nivel;
  String estado;
  String? serie;
  final String color;

  UbicacionEntity({
    required this.id,
    required this.codigo,
    required this.area,
    required this.espacio,
    required this.nivel,
    required this.estado,
    this.serie,
    required this.color,
  });

  factory UbicacionEntity.fromJson(Map<String, dynamic> json) {
    return UbicacionEntity(
      id: json['id']?.toString() ?? '',
      codigo: json['ubicacion_contenedor'] ?? '',
      area: json['area_contenedor'] ?? '',
      espacio: int.tryParse(json['espacio_contenedor'].toString()) ?? 0,
      nivel: int.tryParse(json['nivel_contenedor'].toString()) ?? 0,
      estado: json['estatus'] ?? 'Free',
      serie: json['container_number'],
      color: json['color'] ?? 'green',
    );
  }

  // =========================
  // LÓGICA DE NEGOCIO
  // =========================

  bool get estaLibre => estado.toLowerCase() == 'free';

  bool get estaOcupado => estado.toLowerCase() == 'used';

  bool get tieneSerie => serie != null && serie!.trim().isNotEmpty;

  bool mismaUbicacion(UbicacionEntity other) {
    return area == other.area &&
        espacio == other.espacio &&
        nivel == other.nivel;
  }

  String get ubicacionCompleta => '$area-$espacio-$nivel';
}
