import 'package:segadi/features/maintenance/data/datasources/maintenance_units_remote_datasource.dart';
import 'package:segadi/features/maintenance/data/repositories/maintenance_repository.dart';

import '../../domain/entities/maintenance_unit_assigned.dart';
import '../../domain/entities/maintenance_units_list_entity.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceUnitsRemoteDatasource remoteDataSource;

  MaintenanceRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<MaintenanceUnitAssigned?> getAssignedUnit() {
    return remoteDataSource.getAssignedUnit();
  }

  @override
  Future<List<MaintenanceUnitsListEntity>> getActiveUnits() {
    return remoteDataSource.getActiveUnits();
  }
}
