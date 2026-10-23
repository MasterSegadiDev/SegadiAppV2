import 'package:segadi/features/maintenance/data/repositories/maintenance_repository.dart';

import '../entities/maintenance_units_list_entity.dart';

class GetActiveUnitsUseCase {
  final MaintenanceRepository repository;

  const GetActiveUnitsUseCase(this.repository);

  Future<List<MaintenanceUnitsListEntity>> call() {
    return repository.getActiveUnits();
  }
}
