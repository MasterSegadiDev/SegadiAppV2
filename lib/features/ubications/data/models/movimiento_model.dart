import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';

class MovimientoGruaModel extends Movimiento {
  MovimientoGruaModel({
    required super.id,
    required super.folioMovimiento,
    required super.operador,
    required super.tipoMovimiento,
    required super.servicio,
    required super.contenedorA,
    required super.contenedorB,
    required super.contenedorAMover,
    required super.estadoContenedor,
    required super.unidad,
    required super.unidadLocal,
    required super.ubicacionId,
    required super.area,
    required super.espacio,
    required super.nivel,
    required super.estatus,
  });

  factory MovimientoGruaModel.fromJson(Map<String, dynamic> json) {
    return MovimientoGruaModel(
      id: json['id'] as int,
      folioMovimiento: json['crane_movement'] ?? '',
      operador: json['crane_operator'] ?? '',
      tipoMovimiento: json['movement_type'] ?? '',
      servicio: json['service'] ?? '',
      contenedorA: json['container_number_a'] ?? '',
      contenedorB: json['container_number_b'] ?? '',
      contenedorAMover: json['container_to_move'] ?? '',
      estadoContenedor: json['container_status'] ?? '',
      unidad: json['unit'] ?? '',
      unidadLocal: json['local_unit'] ?? '',
      ubicacionId: json['container_location_id'] ?? '',
      area: json['area'] ?? '',
      espacio: json['space'] ?? '',
      nivel: json['level'] ?? '',
      estatus: json['status'] ?? '',
    );
  }
}
