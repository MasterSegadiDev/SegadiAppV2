class Ubicacion {
  final String id;
  final String area;
  final String espacio;
  final String nivel;
  final String codigo;

  String? color;
  String estado;
  String? numberSerie;

  Ubicacion({
    required this.id,
    required this.area,
    required this.espacio,
    required this.nivel,
    required this.codigo,
    this.color,
    required this.estado,
    this.numberSerie,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
        id: json['id'],
        area: json['area_contenedor'],
        espacio: json['espacio_contenedor'] ?? " ",
        nivel: (json['ubicacion_contenedor'] ?? '').toString().split('-').last,
        codigo: json['ubicacion_contenedor'],
        color: json['color'],
        estado: json['estatus'] ?? '',
        numberSerie: json['container_number'] ?? '',
      );
}
