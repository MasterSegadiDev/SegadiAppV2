import 'package:segadi/features/local_service/domain/entities/stretch.dart';

import '../../domain/enums/tramo_status.dart';

abstract class TramoRemoteDataSource {
  Future<Tramo?> getActiveTramo(
    String operadorId,
  );

  Future<void> updateStatus({
    required String referralId,
    required int tramoIndex,
    required TramoStatus status,
  });
}
