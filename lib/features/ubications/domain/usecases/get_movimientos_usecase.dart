import 'package:dartz/dartz.dart';
import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';
import 'package:segadi/features/ubications/domain/repositories/movimientos_repository.dart';

class GetMovimientosUseCase {
  final MovimientoRepository repository;

  GetMovimientosUseCase(this.repository);

  Future<Either<String, List<Movimiento>>> execute(String siteId) async {
    return await repository.getMovimientos(siteId);
  }
}
