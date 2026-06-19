import 'package:segadi/features/ubications/data/datasources/ubicaciones_remote_datasource.dart';
import 'package:segadi/features/ubications/data/models/ubicaciones_mapa_model.dart';
import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/domain/repositories/ubicaciones_repository.dart';

import 'package:segadi/core/utils/user_session.dart';

class UbicacionesRepositoryImpl implements UbicacionesRepository {
  final UbicacionesRemoteDataSource remoteDataSource;

  UbicacionesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UbicacionesMapEntity>> getMapaUbicaciones() async {
    try {
      final session = UserSession();
      await session.loadFromPrefs();

      print(
          "🔍 Repository: Obteniendo mapa de ubicaciones para site_id: ${session.siteId}");

      final InventarioMapaModel mapaModel = await remoteDataSource
          .fetchMapaUbicaciones(session.siteId.toString());

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
