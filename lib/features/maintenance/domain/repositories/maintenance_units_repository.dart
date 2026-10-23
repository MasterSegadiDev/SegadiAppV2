import '../entities/unit_selection_data.dart';

abstract class MaintenanceUnitsRepository {
  Future<UnitSelectionData> loadUnits();
}
