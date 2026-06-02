import 'package:dartz/dartz.dart';
import 'package:segadi/features/ubications/data/datasources/movimientos_list_datasource.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_entity.dart';
import 'package:segadi/features/ubications/data/models/movimiento_grua_model.dart';
import 'package:segadi/features/ubications/domain/repositories/movimientos_repository.dart';

class MovimientosListRepositoryImpl implements MovimientoRepository {
  final MovimientoRemoteDataSource remoteDataSource;

  MovimientosListRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<String, List<MovimientoEntity>>> getMovimientos(
      String siteId) async {
    try {
      final List<MovimientoGruaModel> models =
          await remoteDataSource.fetchMovimientos(siteId);

      return Right(models);
    } catch (e) {
      return Left("Error: $e");
    }
  }
}
