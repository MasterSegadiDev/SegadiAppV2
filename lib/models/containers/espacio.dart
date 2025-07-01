class Espacio {
  final String id;
  final String nombre;

  Espacio({required this.id, required this.nombre});

  factory Espacio.fromJson(Map<String, dynamic> json) {
    return Espacio(
      id: json['id'],
      nombre: json['espacio_contenedor'],
    );
  }
}
