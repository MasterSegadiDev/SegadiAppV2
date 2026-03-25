import 'package:segadi/features/ubications/data/datasources/ubicaciones_remote_datasource.dart';
import 'package:segadi/features/ubications/data/models/ubicaciones_mapa_model.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/domain/repositories/ubicaciones_repository.dart';

class UbicacionesRepositoryImpl implements UbicacionesRepository {
  final UbicacionesRemoteDataSource remoteDataSource;

  UbicacionesRepositoryImpl({required this.remoteDataSource});

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
}
