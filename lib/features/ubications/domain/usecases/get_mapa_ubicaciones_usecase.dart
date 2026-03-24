import 'package:segadi/features/ubications/domain/entities/ubicaciones_mapa_entity.dart';
import 'package:segadi/features/ubications/domain/repositories/ubicaciones_repository.dart';

class GetMapaUbicacionesUseCase {
  final UbicacionesRepository repository;

  GetMapaUbicacionesUseCase(this.repository);

  Future<UbicacionesMapEntity?> execute() async {
    final list = await repository.getMapaUbicaciones();
    print("DEBUG USECASE: ¿La lista está vacía? ${list.isEmpty}");
    if (list.isNotEmpty) {
      print("DEBUG USECASE: Primer elemento áreas: ${list.first.areas.length}");
    }
    return list.isNotEmpty ? list.first : null;
  }
}
