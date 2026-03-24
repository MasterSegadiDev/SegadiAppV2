import 'package:dartz/dartz.dart';
import 'package:segadi/features/ubications/data/datasources/ubicaciones_remote_datasource.dart';
import 'package:segadi/features/ubications/data/models/movimiento_model.dart';
import 'package:segadi/features/ubications/data/models/ubicaciones_mapa_model.dart';
import 'package:segadi/features/ubications/domain/entities/movimientos_list_entity.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/domain/repositories/ubicaciones_repository.dart';

class UbicacionesRepositoryImpl implements UbicacionesRepository {
  final UbicacionesRemoteDataSource remoteDataSource;

  UbicacionesRepositoryImpl({required this.remoteDataSource});

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

  @override
  Future<List<UbicacionesMapEntity>> getMapaUbicaciones() async {
    try {
      final InventarioMapaModel mapaModel =
          await remoteDataSource.fetchMapaUbicaciones('2');

      print("✅ Repo: Mapa obtenido con ${mapaModel.areas.length} áreas");
      return [mapaModel];
    } catch (e, stack) {
      // ESTO ES LO QUE NECESITAMOS VER
      print("❌ Error en Repository al mapear: $e");
      print(stack);
      return [];
    }
  }

  @override
  Future<bool> registrarMovimiento({
    required int movimientoId,
    required String ubicacionDestinoId,
    required String comentarios,
  }) async {
    try {
      // Llamamos al DataSource que definimos previamente
      final bool result = await remoteDataSource.registrarMovimiento(
        movimientoId: movimientoId,
        ubicacionDestinoId: ubicacionDestinoId,
        comentarios: comentarios,
      );

      return result;
    } catch (e) {
      // Si algo sale mal en la conexión, retornamos false
      return false;
    }
  }
}
