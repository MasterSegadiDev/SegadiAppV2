import 'package:dartz/dartz.dart';
import 'package:segadi/features/ubications/data/datasources/movimientos_list_datasource.dart';
import 'package:segadi/features/ubications/data/models/movimiento_model.dart';
import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';
import 'package:segadi/features/ubications/domain/repositories/movimientos_repository.dart';

class MovimientosListRepositoryImpl implements MovimientoRepository {
  final MovimientoRemoteDataSource remoteDataSource;

  MovimientosListRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<Movimiento>>> getMovimientos(String siteId) async {
    try {
      final List<MovimientoGruaModel> models =
          await remoteDataSource.fetchMovimientos(siteId);

      // Como MovimientoGruaModel extiende de Movimiento, la conversión es directa
      return Right(models);
    } catch (e) {
      return Left("Error al obtener movimientos: $e");
    }
  }
}
