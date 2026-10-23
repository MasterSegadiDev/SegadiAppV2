import 'package:segadi/features/maintenance/data/repositories/maintenance_repository.dart';

import '../entities/maintenance_unit_assigned.dart';

class GetAssignedUnitUseCase {
  final MaintenanceRepository repository;

  const GetAssignedUnitUseCase(this.repository);

  Future<MaintenanceUnitAssigned?> call() {
    return repository.getAssignedUnit();
  }
}
