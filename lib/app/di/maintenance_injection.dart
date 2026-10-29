import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/core/network/fracttal_api_client.dart';
import 'package:segadi/features/maintenance/data/datasources/maintenance_attachments_remote_datasource.dart';
import 'package:segadi/features/maintenance/data/datasources/maintenance_requests_remote_datasource.dart';
import 'package:segadi/features/maintenance/data/datasources/maintenance_units_remote_datasource_impl.dart';
import 'package:segadi/features/maintenance/domain/usecases/create_maintenance_report_usecase.dart';

import 'injection_container.dart';

import 'package:segadi/features/maintenance/data/datasources/maintenance_units_remote_datasource.dart';
import 'package:segadi/features/maintenance/data/repositories/maintenance_repository.dart';
import 'package:segadi/features/maintenance/data/repositories/maintenance_repository_impl.dart';

import 'package:segadi/features/maintenance/domain/usecases/get_assigned_unit_usecase.dart';
import 'package:segadi/features/maintenance/domain/usecases/get_active_units_usecase.dart';

Future<void> setupMaintenanceDependencies() async {
  // =========================
  // GET Api Fracttal Client
  // =========================

  getIt.registerLazySingleton<FracttalApiClient>(
    () => FracttalApiClient(
      segadiDio: DioClient.instance,
    ),
  );

  // ==========================
  // DataSources
  // ==========================

  getIt.registerLazySingleton<MaintenanceUnitsRemoteDatasource>(
    () => MaintenanceUnitsRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<MaintenanceRequestsRemoteDataSource>(
    () => MaintenanceRequestsRemoteDataSource(
      getIt<FracttalApiClient>(),
    ),
  );

  getIt.registerLazySingleton<MaintenanceAttachmentsRemoteDataSource>(
    () => MaintenanceAttachmentsRemoteDataSource(
      getIt<FracttalApiClient>(),
    ),
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

  getIt.registerLazySingleton<CreateMaintenanceReportUseCase>(
    () => CreateMaintenanceReportUseCase(
      getIt<MaintenanceRequestsRemoteDataSource>(),
      getIt<MaintenanceAttachmentsRemoteDataSource>(),
    ),
  );
}
