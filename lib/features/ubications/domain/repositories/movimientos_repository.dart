import 'package:dartz/dartz.dart';

import '../entities/movimiento_entity.dart';

abstract class MovimientoRepository {
  Future<Either<String, List<MovimientoEntity>>> getMovimientos(
    String siteId,
  );
}
