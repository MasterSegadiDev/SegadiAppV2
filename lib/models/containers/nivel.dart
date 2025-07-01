class Nivel {
  final String id;
  final String nombre;

  Nivel({required this.id, required this.nombre});

  factory Nivel.fromJson(Map<String, dynamic> json) {
    return Nivel(
      id: json['id'],
      nombre: json['nivel_contenedor'],
    );
  }
}
