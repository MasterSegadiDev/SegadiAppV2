import 'package:segadi/features/local_service/domain/repositories/stretch_repository.dart';

import '../enums/tramo_status.dart';

class UpdateTramoStatusUseCase {
  final TramoRepository repository;

  UpdateTramoStatusUseCase(
    this.repository,
  );

  Future<void> call({
    required String referralId,
    required int tramoIndex,
    required TramoStatus status,
  }) {
    return repository.updateStatus(
      referralId: referralId,
      tramoIndex: tramoIndex,
      status: status,
    );
  }
}
