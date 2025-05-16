class Ubicacion {
  final String id;
  final String area;
  final String espacio;
  final String nivel;
  final String codigo;
  final String color;

  Ubicacion({
    required this.id,
    required this.area,
    required this.espacio,
    required this.nivel,
    required this.codigo,
    required this.color,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      id: json['id'],
      area: json['area_contenedor'],
      espacio: json['espacio_contenedor'],
      nivel: json['ubicacion_contenedor'].split('-').last, // Ej: "1"
      codigo: json['ubicacion_contenedor'],
      color: json['color'],
    );
  }
}
