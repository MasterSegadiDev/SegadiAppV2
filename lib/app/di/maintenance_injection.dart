import 'package:segadi/features/maintenance/data/datasources/maintenance_units_remote_datasource_impl.dart';

import 'injection_container.dart';

import 'package:segadi/features/maintenance/data/datasources/maintenance_units_remote_datasource.dart';
import 'package:segadi/features/maintenance/data/repositories/maintenance_repository.dart';
import 'package:segadi/features/maintenance/data/repositories/maintenance_repository_impl.dart';

import 'package:segadi/features/maintenance/domain/usecases/get_assigned_unit_usecase.dart';
import 'package:segadi/features/maintenance/domain/usecases/get_active_units_usecase.dart';

Future<void> setupMaintenanceDependencies() async {
  // ==========================
  // DataSources
  // ==========================

  getIt.registerLazySingleton<MaintenanceUnitsRemoteDatasource>(
    () => MaintenanceUnitsRemoteDataSourceImpl(),
  );

  // ==========================
  // Repositories
  // ==========================

  getIt.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(
      remoteDataSource: getIt<MaintenanceUnitsRemoteDatasource>(),
    ),
  );

  // ==========================
  // UseCases
  // ==========================

  getIt.registerLazySingleton<GetAssignedUnitUseCase>(
    () => GetAssignedUnitUseCase(
      getIt<MaintenanceRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetActiveUnitsUseCase>(
    () => GetActiveUnitsUseCase(
      getIt<MaintenanceRepository>(),
    ),
  );
}
