import 'maintenance_unit_assigned.dart';

class UnitSelectionData {
  final MaintenanceUnitAssigned? assignedUnit;
  final List<MaintenanceUnitAssigned> activeUnits;
  const UnitSelectionData(
      {required this.assignedUnit, required this.activeUnits});
}
