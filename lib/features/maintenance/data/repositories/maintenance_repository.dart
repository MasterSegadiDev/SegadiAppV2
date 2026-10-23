import 'package:segadi/features/maintenance/domain/entities/maintenance_unit_assigned.dart';
import 'package:segadi/features/maintenance/domain/entities/maintenance_units_list_entity.dart';

abstract class MaintenanceRepository {
  Future<MaintenanceUnitAssigned?> getAssignedUnit();
  Future<List<MaintenanceUnitsListEntity>> getActiveUnits();
}
