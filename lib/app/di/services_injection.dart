import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/services/data/datasources/services_remote_data_source.dart';
import 'package:segadi/features/services/data/datasources/services_remote_data_source_impl.dart';
import 'package:segadi/features/services/data/repository/service_repository_impl.dart';
import 'package:segadi/features/services/domain/repository/services_repository.dart';
import 'package:segadi/features/services/domain/usecases/get_assigned_services_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_actions_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_detail_service_info_general_usecase.dart';
import 'package:segadi/features/services/domain/usecases/get_service_status_usecase.dart';
import 'package:segadi/features/services/domain/usecases/update_mandatory_status_usecase.dart';
import 'package:segadi/features/services/presentation/viewmodels/service_detail_viewmodel.dart';

Future<void> setupServicesDependencies() async {
  /// Datasource
  getIt.registerLazySingleton<ServicesRemoteDatasource>(
    () => ServicesRemoteDatasourceImpl(),
  );

  /// Repository
  getIt.registerLazySingleton<ServiceRepository>(
    () => ServicesRepositoryImpl(
      remoteDataSource: getIt<ServicesRemoteDatasource>(),
    ),
  );

  /// UseCase - Assigned Services
  getIt.registerLazySingleton<GetAssignedServicesUseCase>(
    () => GetAssignedServicesUseCase(
      getIt<ServiceRepository>(),
    ),
  );

  /// UseCase - Service General
  getIt.registerLazySingleton<GetServiceGeneralUseCase>(
    () => GetServiceGeneralUseCase(
      getIt<ServiceRepository>(),
    ),
  );

  /// UseCase - Service Actions
  getIt.registerLazySingleton<GetServiceActionsUseCase>(
    () => GetServiceActionsUseCase(
      getIt<ServiceRepository>(),
    ),
  );

  /// UseCase - Service Status
  getIt.registerLazySingleton<GetServiceStatusUseCase>(
    () => GetServiceStatusUseCase(
      repository: getIt<ServiceRepository>(),
    ),
  );

  /// UseCase - Update Mandatory Status
  getIt.registerLazySingleton<UpdateMandatoryStatusUseCase>(
    () => UpdateMandatoryStatusUseCase(
      getIt<ServiceRepository>(),
    ),
  );

  /// ViewModel - Service Detail
  getIt.registerFactory<ServiceDetailViewModel>(
    () => ServiceDetailViewModel(
      getServiceGeneralUseCase: getIt<GetServiceGeneralUseCase>(),
      getServiceActionsUseCase: getIt<GetServiceActionsUseCase>(),
      getServiceStatusUseCase: getIt<GetServiceStatusUseCase>(),
      updateMandatoryStatusUseCase: getIt<UpdateMandatoryStatusUseCase>(),
    ),
  );
}
