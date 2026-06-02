import 'package:dartz/dartz.dart';
import 'package:segadi/features/ubications/domain/repositories/movimientos_repository.dart';

import '../entities/movimiento_entity.dart';

class GetMovimientosUseCase {
  final MovimientoRepository repository;

  GetMovimientosUseCase(this.repository);

  Future<Either<String, List<MovimientoEntity>>> execute(String siteId) async {
    return await repository.getMovimientos(siteId);
  }
}
