import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';

abstract class UbicacionesRepository {
  Future<List<UbicacionesMapEntity>> getMapaUbicaciones();
}
