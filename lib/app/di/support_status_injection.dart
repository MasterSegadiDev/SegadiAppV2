import 'package:get_it/get_it.dart';

import 'package:segadi/features/support_status/data/datasource/support_status_remote_datasource.dart';
import 'package:segadi/features/support_status/data/datasource/support_status_remote_datasource_impl.dart';
import 'package:segadi/features/support_status/data/repositories/support_status_repository_impl.dart';

import 'package:segadi/features/support_status/domain/repositories/support_status_repository.dart';
import 'package:segadi/features/support_status/domain/usecases/get_support_status_usecase.dart';
import 'package:segadi/features/support_status/domain/usecases/send_support_status_usecase.dart';

import 'package:segadi/features/support_status/presentation/viewmodel/support_status_viewmodel.dart';

void registerSupportStatusDependencies(
  GetIt sl,
) {
  // ----------------------------------------------------------
  // DataSource
  // ----------------------------------------------------------

  sl.registerLazySingleton<SupportStatusRemoteDatasource>(
    () => SupportStatusRemoteDatasourceImpl(),
  );

  // ----------------------------------------------------------
  // Repository
  // ----------------------------------------------------------

  sl.registerLazySingleton<SupportStatusRepository>(
    () => SupportStatusRepositoryImpl(
      remoteDatasource: sl<SupportStatusRemoteDatasource>(),
    ),
  );

  // ----------------------------------------------------------
  // UseCase - Obtener catálogo de estatus
  // ----------------------------------------------------------

  sl.registerLazySingleton<GetSupportStatusUseCase>(
    () => GetSupportStatusUseCase(
      repository: sl<SupportStatusRepository>(),
    ),
  );

  // ----------------------------------------------------------
  // UseCase - Enviar estatus seleccionado
  // ----------------------------------------------------------

  sl.registerLazySingleton<SendSupportStatusUseCase>(
    () => SendSupportStatusUseCase(
      repository: sl<SupportStatusRepository>(),
    ),
  );

  // ----------------------------------------------------------
  // ViewModel
  // ----------------------------------------------------------

  sl.registerFactory<SupportStatusViewModel>(
    () => SupportStatusViewModel(
      getSupportStatusUseCase: sl<GetSupportStatusUseCase>(),
      sendSupportStatusUseCase: sl<SendSupportStatusUseCase>(),
    ),
  );
}
