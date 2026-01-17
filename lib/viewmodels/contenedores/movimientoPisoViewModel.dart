import 'package:flutter/foundation.dart';
import 'package:segadi/models/contenedores/punto_movimiento.dart';
import 'package:segadi/services/contenedores/movimientos_service.dart';
import 'package:segadi/models/contenedores/movimiento.dart';
import 'package:segadi/viewmodels/contenedores/tiposMovimientosViewModel.dart';

class MovimientoFlowResult {
  final String? error;
  final String? info;
  final String? confirmText;
  final bool readyToExecute;
  final String? serie;

  const MovimientoFlowResult({
    this.error,
    this.info,
    this.confirmText,
    this.readyToExecute = false,
    this.serie,
  });
}

class MovimientoPisoViewModel extends ChangeNotifier {
  final MovimientosService _service = MovimientosService();

  MovimientoFlowResult handleNivelSeleccionado({
    required String tipoMovimiento,
    required PuntoMovimiento? origen,
    required PuntoMovimiento? destino,
    required String? serieCamion,
  }) {
    if (tipoMovimiento == MovementTypes.pisoCamion) {
      if (origen == null ||
          origen.numeroSerie == null ||
          origen.numeroSerie!.trim().isEmpty) {
        return const MovimientoFlowResult(
            error: 'Selecciona un nivel OCCUPADO como origen.');
      }
      return MovimientoFlowResult(
        confirmText:
            '¿Confirmas mover el contenedor ${origen.numeroSerie} al camión?',
        readyToExecute: true,
        serie: origen.numeroSerie,
      );
    }

    if (tipoMovimiento == MovementTypes.camionPiso) {
      if (destino == null)
        return const MovimientoFlowResult(
            error: 'Selecciona un destino vacío.');
      if (serieCamion == null || serieCamion.trim().isEmpty) {
        return const MovimientoFlowResult(
            error: 'No hay número de contenedor seleccionado en el camión.');
      }
      return MovimientoFlowResult(
        confirmText:
            '¿Confirmas bajar el contenedor $serieCamion a ${destino.area}-${destino.espacio} nivel ${destino.nivel}?',
        readyToExecute: true,
        serie: serieCamion,
      );
    }

    // reacomodo
    if (origen == null || destino == null) {
      return const MovimientoFlowResult(
          info: 'Selecciona primero origen (ocupado) y luego destino (vacío).');
    }

    return MovimientoFlowResult(
      confirmText:
          '¿Confirmas mover el contenedor ${origen.numeroSerie} de ${origen.area}-${origen.espacio}-${origen.nivel} '
          'a ${destino.area}-${destino.espacio}-${destino.nivel}?',
      readyToExecute: true,
      serie: origen.numeroSerie,
    );
  }

  Future<void> ejecutarMovimiento({
    required String movementType,
    required String siteId,
    required String userId,
    required String token,
    String? craneMovementId,
    String? contenedorActualId,
    String? contenedorNuevoId,
    String? numberSerie,
  }) async {
    final mov = Movimiento(
      movement_type: movementType,
      crane_operator_id: userId,
      token: token,
      site_id: siteId,
      crane_movement_id:
          craneMovementId == null ? null : int.tryParse(craneMovementId),
      container_location_id:
          contenedorActualId == null ? null : int.tryParse(contenedorActualId),
      new_container_location_id: contenedorNuevoId,
      container_number: numberSerie,
    );

    await _service.saveMovimiento(mov);
  }
}
