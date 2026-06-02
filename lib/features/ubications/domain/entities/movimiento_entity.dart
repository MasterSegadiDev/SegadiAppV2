import 'package:segadi/features/ubications/enums/contenedor_objetivo.dart';
import 'package:segadi/features/ubications/enums/tipo_movimiento.dart';

class MovimientoEntity {
  final int id;
  final String folio;
  final TipoMovimiento tipo;

  final String servicio;
  final String operador;
  final String unidad;
  final String localUnidad;

  final String estadoContenedor;

  final String? contenedorA;
  final String? contenedorB;

  final ContenedorObjetivo? contenedorObjetivo;

  final String area;
  final int espacio;
  final int nivel;

  final String ubicacionId;

  final String estatus;
  final String operadorLocal;
  final String comentarios;

  const MovimientoEntity({
    required this.id,
    required this.folio,
    required this.tipo,
    required this.servicio,
    required this.operador,
    required this.unidad,
    required this.localUnidad,
    required this.estadoContenedor,
    required this.contenedorA,
    required this.contenedorB,
    required this.contenedorObjetivo,
    required this.area,
    required this.espacio,
    required this.nivel,
    required this.ubicacionId,
    required this.estatus,
    required this.operadorLocal,
    required this.comentarios,
  });

  String get serieObjetivo {
    switch (contenedorObjetivo ?? ContenedorObjetivo.a) {
      case ContenedorObjetivo.a:
        return contenedorA ?? '';
      case ContenedorObjetivo.b:
        return contenedorB ?? '';
    }
  }

  bool get esPisoCamion => tipo == TipoMovimiento.pisoCamion;
  bool get esCamionPiso => tipo == TipoMovimiento.camionPiso;
  bool get esReacomodo => tipo == TipoMovimiento.reacomodoManual;
}
