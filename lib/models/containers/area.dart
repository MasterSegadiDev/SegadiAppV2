class Area {
  final String id;
  final String nombre;

  Area({required this.id, required this.nombre});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      nombre: json['area_contenedor'],
    );
  }
}
