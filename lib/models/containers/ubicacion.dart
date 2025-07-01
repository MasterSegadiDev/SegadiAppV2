class UbicacionList {
  final String id;
  final String codigo;
  final String area;
  final String espacio;
  final String nivel;
  final String? areaId;
  final String? espacioId;
  final String? nivelId;
  final String estado;
  final String? containerNumber;

  UbicacionList({
    required this.id,
    required this.codigo,
    required this.area,
    required this.espacio,
    required this.nivel,
    this.areaId,
    this.espacioId,
    this.nivelId,
    required this.estado,
    this.containerNumber,
  });

  factory UbicacionList.fromJson(Map<String, dynamic> json) {
    return UbicacionList(
      id: json['id'],
      codigo: json['ubicacion_contenedor'],
      area: json['area_contenedor'],
      espacio: json['espacio_contenedor'],
      nivel: json['nivel_contenedor'],
      areaId: json['areas_contenedores_id'],
      espacioId: json['espacios_contenedores_id'],
      nivelId: json['niveles_contenedores_id'],
      estado: json['estatus'],
      containerNumber: json['container_number'],
    );
  }
}
