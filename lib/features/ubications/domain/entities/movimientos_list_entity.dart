//entidad del listado de movimiento de gruas

class Movimiento {
  final int id;
  final String folioMovimiento; // crane_movement
  final String operador;
  final String tipoMovimiento; // movement_type
  final String servicio; // service
  final String contenedorA; // container_number_a
  final String contenedorB; // container_number_b
  final String contenedorAMover; // container_to_move
  final String estadoContenedor; // container_status (Lleno/Vacío)
  final String unidad; // unit
  final String unidadLocal;
  final String ubicacionId; // container_location_id
  final String area;
  final String espacio; // space
  final String nivel; // level
  final String estatus;

  Movimiento({
    required this.id,
    required this.folioMovimiento,
    required this.operador,
    required this.tipoMovimiento,
    required this.servicio,
    required this.contenedorA,
    required this.contenedorB,
    required this.contenedorAMover,
    required this.estadoContenedor,
    required this.unidad,
    required this.unidadLocal,
    required this.ubicacionId,
    required this.area,
    required this.espacio,
    required this.nivel,
    required this.estatus,
  });

  String get serieReal =>
      (contenedorAMover == "Contenedor A") ? contenedorA : contenedorB;
}
