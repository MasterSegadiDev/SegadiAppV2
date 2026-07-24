import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/services_assigned/data/datasources/services_remote_data_source.dart';
import 'package:segadi/features/services_assigned/data/datasources/services_remote_data_source_impl.dart';
import 'package:segadi/features/services_assigned/data/repository/service_repository_impl.dart';
import 'package:segadi/features/services_assigned/domain/repository/services_repository.dart';
import 'package:segadi/features/services_assigned/domain/usecases/get_assigned_services_usecase.dart';

Future<void> setupServicesDependencies() async {
  /// Datasource
  getIt.registerLazySingleton<ServicesRemoteDatasource>(
    () => ServicesRemoteDatasourceImpl(),
  );

  /// Repository
  getIt.registerLazySingleton<ServicesRepository>(
    () => ServicesRepositoryImpl(
      remoteDatasource: getIt(),
    ),
  );

  /// UseCase
  getIt.registerLazySingleton(
    () => GetAssignedServicesUseCase(
      getIt(),
    ),
  );
}
