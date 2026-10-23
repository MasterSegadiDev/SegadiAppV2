import 'package:segadi/features/maintenance/data/models/maintenance_unit_assigned_model.dart';
import 'package:segadi/features/maintenance/data/models/maintenance_units_list_model.dart';

abstract class MaintenanceUnitsRemoteDatasource {
  Future<List<MaintenanceUnitModel>> getActiveUnits();
  Future<MaintenanceUnitDetailModel?> getAssignedUnit();
}
