import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/services/data/datasources/services_remote_data_source.dart';
import 'package:segadi/features/services/data/datasources/services_remote_data_source_impl.dart';
import 'package:segadi/features/services/data/repository/service_repository_impl.dart';
import 'package:segadi/features/services/domain/repository/services_repository.dart';
import 'package:segadi/features/services/domain/usecases/get_assigned_services_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_service_detail_usecase.dart';
import 'package:segadi/features/services/presentation/viewmodels/service_detail_viewmodel.dart';

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

  //UseCase ServiceDetail
  getIt.registerLazySingleton(
    () => GetServiceDetailUseCase(
      getIt(),
    ),
  );

  //viewModel ServiceDetail
  getIt.registerFactory(
    () => ServiceDetailViewModel(
      getServiceDetailUseCase: getIt(),
    ),
  );
}
