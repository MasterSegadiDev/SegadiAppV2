import 'package:segadi/features/local_service/domain/entities/container.dart';
import 'package:segadi/features/local_service/domain/entities/stop.dart';
import 'package:segadi/features/local_service/domain/entities/stretch.dart';

import '../../domain/enums/parada_accion.dart';
import '../../domain/enums/parada_tipo.dart';
import '../../domain/enums/tramo_status.dart';

class TramoModel {
  static Tramo fromJson(
    Map<String, dynamic> json,
  ) {
    final tramoJson = json['tramo'] as Map<String, dynamic>;

    final contenedoresJson =
        tramoJson['arrContenedores'] as List<dynamic>? ?? [];

    final paradasJson = tramoJson['arrParadas'] as List<dynamic>? ?? [];

    return Tramo(
      referralId: json['referral_id'] as String,
      tramoIndex: json['tramo_index'] as int,
      operadorId: tramoJson['strOperadorId'] as String,
      operadorName: tramoJson['strOperadorName'] as String,
      unidadId: tramoJson['strUnidadId'] as String,
      status: TramoStatus.fromApi(
        tramoJson['status'] as String,
      ),
      contenedores: contenedoresJson
          .map(
            (item) => Contenedor(
              numero: item['numero'] as String,
              tamano: item['tamano'] as String,
            ),
          )
          .toList(),
      paradas: paradasJson
          .map(
            (item) => Parada(
              tipo: ParadaTipo.fromApi(
                item['tipo'] as String,
              ),
              accion: ParadaAccion.fromApi(
                item['accion'] as String,
              ),
              domicilio: item['domicilio'] as String,
            ),
          )
          .toList(),
    );
  }
}
