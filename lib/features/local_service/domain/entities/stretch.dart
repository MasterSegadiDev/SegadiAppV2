import 'package:segadi/features/local_service/domain/entities/container.dart';
import 'package:segadi/features/local_service/domain/entities/stop.dart';

import '../enums/tramo_status.dart';

class Tramo {
  final String referralId;
  final int tramoIndex;

  final String operadorId;
  final String operadorName;
  final String unidadId;

  final TramoStatus status;

  final List<Contenedor> contenedores;
  final List<Parada> paradas;

  const Tramo({
    required this.referralId,
    required this.tramoIndex,
    required this.operadorId,
    required this.operadorName,
    required this.unidadId,
    required this.status,
    required this.contenedores,
    required this.paradas,
  });

  Tramo copyWith({
    TramoStatus? status,
  }) {
    return Tramo(
      referralId: referralId,
      tramoIndex: tramoIndex,
      operadorId: operadorId,
      operadorName: operadorName,
      unidadId: unidadId,
      status: status ?? this.status,
      contenedores: contenedores,
      paradas: paradas,
    );
  }
}
