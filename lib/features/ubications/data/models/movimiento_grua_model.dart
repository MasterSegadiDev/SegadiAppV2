import 'package:segadi/features/ubications/domain/entities/movimiento_entity.dart';
import 'package:segadi/features/ubications/enums/contenedor_objetivo.dart';
import 'package:segadi/features/ubications/enums/tipo_movimiento.dart';

class MovimientoGruaModel extends MovimientoEntity {
  MovimientoGruaModel({
    required super.id,
    required super.folio,
    required super.tipo,
    required super.servicio,
    required super.operador,
    required super.unidad,
    required super.localUnidad,
    required super.estadoContenedor,
    required super.contenedorA,
    required super.contenedorB,
    required super.contenedorObjetivo,
    required super.area,
    required super.espacio,
    required super.nivel,
    required super.ubicacionId,
    required super.estatus,
    required super.operadorLocal,
    required super.comentarios,
  });

  factory MovimientoGruaModel.fromJson(Map<String, dynamic> json) {
    final tipo = _mapTipoMovimiento(json['movement_type']);

    print("TIPO RAW => ${json['movement_type']}");
    print("TIPO PARSEADO => $tipo");

    return MovimientoGruaModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      folio: json['crane_movement'] ?? '',
      tipo: tipo,
      servicio: json['service'] ?? '',
      operador: json['crane_operator'] ?? '',
      unidad: json['unit'] ?? '',
      localUnidad: json['local_unit'] ?? '',
      estadoContenedor: json['container_status'] ?? '',
      contenedorA: json['container_number_a'] ?? '',
      contenedorB: json['container_number_b'] ?? '',
      contenedorObjetivo: _mapContenedor(json['container_to_move']),
      area: json['area'] ?? '',
      espacio: int.tryParse(json['space'].toString()) ?? 0,
      nivel: int.tryParse(json['level'].toString()) ?? 0,
      ubicacionId: json['container_location_id'] ?? '',
      estatus: json['status'] ?? '',
      operadorLocal: json['local_operator'] ?? '',
      comentarios: json['comments'] ?? '',
    );
  }

  static TipoMovimiento _mapTipoMovimiento(dynamic value) {
    final v = value?.toString().toLowerCase().trim() ?? '';

    if (v.contains('piso-camion')) return TipoMovimiento.pisoCamion;
    if (v.contains('camion-piso')) return TipoMovimiento.camionPiso;
    if (v.contains('reacomodo')) return TipoMovimiento.reacomodoManual;
    if (v.contains('pesaje')) return TipoMovimiento.pesaje;

    return TipoMovimiento.ninguno;
  }

  static ContenedorObjetivo _mapContenedor(dynamic value) {
    final v = value?.toString().toLowerCase() ?? '';

    if (v.contains('b')) return ContenedorObjetivo.b;
    return ContenedorObjetivo.a;
  }
}
