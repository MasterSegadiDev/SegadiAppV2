class PuntoMovimiento {
  final String area;
  final String espacio;
  final String nivel;
  final String? numeroSerie;

  const PuntoMovimiento({
    required this.area,
    required this.espacio,
    required this.nivel,
    this.numeroSerie,
  });

  @override
  String toString() => '$area-$espacio-$nivel';
}
