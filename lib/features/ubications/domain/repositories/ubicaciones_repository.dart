import 'package:dartz/dartz.dart';
import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';

abstract class UbicacionesRepository {
  Future<Either<String, List<Movimiento>>> getMovimientos(String siteId);
  Future<List<UbicacionesMapEntity>> getMapaUbicaciones();
  Future<bool> registrarMovimiento({
    required int movimientoId,
    required String ubicacionDestinoId,
    required String comentarios,
  });
}
