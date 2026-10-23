import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segadi/app/di/injection_container.dart';

import '../../domain/entities/maintenance_unit_assigned.dart';
import '../../domain/entities/maintenance_units_list_entity.dart';

import '../../domain/usecases/get_assigned_unit_usecase.dart';
import '../../domain/usecases/get_active_units_usecase.dart';

// ==========================
// UNIDAD ASIGNADA
// ==========================

final assignedUnitProvider = FutureProvider<MaintenanceUnitAssigned?>((ref) {
  return getIt<GetAssignedUnitUseCase>().call();
});

// ==========================
// UNIDADES ACTIVAS
// ==========================

final activeUnitsProvider =
    FutureProvider<List<MaintenanceUnitsListEntity>>((ref) {
  return getIt<GetActiveUnitsUseCase>().call();
});
