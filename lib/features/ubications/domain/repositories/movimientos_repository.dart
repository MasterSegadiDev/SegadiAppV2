import 'package:dartz/dartz.dart';
import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';

abstract class MovimientoRepository {
  Future<Either<String, List<Movimiento>>> getMovimientos(String siteId);
}
