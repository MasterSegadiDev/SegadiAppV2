import 'package:flutter/foundation.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicacion_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/enums/tipo_movimiento.dart';

enum EstadoVisualEspacio {
  normal,
  objetivo,
  bloqueador,
  origenManual,
  destinoManual,
  destinoValido,
  destinoInvalido,
}

enum PasoMovimiento {
  idle,

  // Piso -> Camión
  validarOrden,
  seleccionarContenedorBloqueador,
  seleccionarDestinoReacomodo,
  confirmarSalida,

  // Camión -> Piso
  seleccionarDestinoIngreso,
  confirmarIngreso,

  // Reacomodo Manual
  seleccionarOrigenManual,
  seleccionarDestinoManual,
  confirmarReacomodo,

  completado,
  error,
}

@immutable
class MapaMovimientoState {
  final bool isLoading;

  final bool isRegistrandoMovimiento;

  final String? error;
  final String? mensaje;

  final TipoMovimiento tipoMovimiento;
  final PasoMovimiento paso;

  final MovimientoEntity? ordenActiva;

  final UbicacionEntity? origen;
  final UbicacionEntity? destino;

  /// Contenedor principal del movimiento
  final UbicacionEntity? contenedorObjetivo;

  /// Contenedor que bloquea al objetivo
  final UbicacionEntity? bloqueador;

  final UbicacionesMapEntity? mapa;

  //final MovimientoEntity? movimiento;

  final UbicacionEntity? ubicacionDestino;

  final List<UbicacionEntity> bloqueadores;

  const MapaMovimientoState({
    required this.isLoading,
    required this.error,
    required this.mensaje,
    required this.tipoMovimiento,
    required this.paso,
    required this.ordenActiva,
    required this.origen,
    required this.destino,
    required this.contenedorObjetivo,
    required this.bloqueador,
    required this.mapa,
    //this.movimiento,
    this.ubicacionDestino,
    required this.bloqueadores,
    required this.isRegistrandoMovimiento,
  });

  factory MapaMovimientoState.initial() {
    return const MapaMovimientoState(
      isLoading: false,
      error: null,
      mensaje: null,
      tipoMovimiento: TipoMovimiento.ninguno,
      paso: PasoMovimiento.idle,
      ordenActiva: null,
      origen: null,
      destino: null,
      contenedorObjetivo: null,
      bloqueador: null,
      mapa: null,
      bloqueadores: const [],
      isRegistrandoMovimiento: false,
    );
  }

  MapaMovimientoState copyWith({
    bool? isLoading,
    String? error,
    String? mensaje,
    TipoMovimiento? tipoMovimiento,
    PasoMovimiento? paso,
    MovimientoEntity? ordenActiva,
    UbicacionEntity? origen,
    UbicacionEntity? destino,
    UbicacionEntity? contenedorObjetivo,
    UbicacionEntity? bloqueador,
    UbicacionesMapEntity? mapa,
    bool clearError = false,
    bool clearMensaje = false,
    bool clearOrigen = false,
    bool clearDestino = false,
    bool clearBloqueador = false,
    MovimientoEntity? movimiento,
    UbicacionEntity? ubicacionDestino,
    List<UbicacionEntity>? bloqueadores,
    bool? isRegistrandoMovimiento,
  }) {
    return MapaMovimientoState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      mensaje: clearMensaje ? null : mensaje ?? this.mensaje,
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      paso: paso ?? this.paso,
      ordenActiva: ordenActiva ?? this.ordenActiva,
      origen: clearOrigen ? null : origen ?? this.origen,
      destino: clearDestino ? null : destino ?? this.destino,
      contenedorObjetivo: contenedorObjetivo ?? this.contenedorObjetivo,
      bloqueador: clearBloqueador ? null : bloqueador ?? this.bloqueador,
      mapa: mapa ?? this.mapa,
      //movimiento: movimiento ?? this.movimiento,
      ubicacionDestino: ubicacionDestino ?? this.ubicacionDestino,
      bloqueadores: bloqueadores ?? this.bloqueadores,
      isRegistrandoMovimiento:
          isRegistrandoMovimiento ?? this.isRegistrandoMovimiento,
    );
  }

  bool get hayOrden => ordenActiva != null;

  bool get hayOrigen => origen != null;

  bool get hayDestino => destino != null;

  bool get hayBloqueador => bloqueador != null;

  bool get esReacomodo => tipoMovimiento == TipoMovimiento.reacomodoManual;
  //|| tipoMovimiento == TipoMovimiento.reacomodoAutomatico;

  bool get esPisoCamion => tipoMovimiento == TipoMovimiento.pisoCamion;

  bool get esCamionPiso => tipoMovimiento == TipoMovimiento.camionPiso;
}
