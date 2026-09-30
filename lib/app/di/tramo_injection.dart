import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/features/local_service/data/datasources/stretch_remote_data_source.dart';
import 'package:segadi/features/local_service/data/datasources/stretch_remote_data_source_impl.dart';
import 'package:segadi/features/local_service/data/repositories/stretch_repository_impl.dart';
import 'package:segadi/features/local_service/domain/repositories/stretch_repository.dart';
import 'package:segadi/features/local_service/domain/usecases/get_active_stretch.dart';
import 'package:segadi/features/local_service/domain/usecases/update_stretch_status.dart';
import 'package:segadi/features/local_service/presentation/viewmodels/stretch_viewmodel.dart';

Future<void> setupTramoDependencies() async {
  /// DataSource
  getIt.registerLazySingleton<TramoRemoteDataSource>(
    () => TramoRemoteDataSourceImpl(),
  );

  /// Repository
  getIt.registerLazySingleton<TramoRepository>(
    () => TramoRepositoryImpl(
      remoteDataSource: getIt<TramoRemoteDataSource>(),
    ),
  );

  /// UseCase - Obtener tramo activo
  getIt.registerLazySingleton<GetActiveTramoUseCase>(
    () => GetActiveTramoUseCase(
      getIt<TramoRepository>(),
    ),
  );

  /// UseCase - Actualizar estado
  getIt.registerLazySingleton<UpdateTramoStatusUseCase>(
    () => UpdateTramoStatusUseCase(
      getIt<TramoRepository>(),
    ),
  );

  /// ViewModel
  getIt.registerFactory<TramoViewModel>(
    () => TramoViewModel(
      getActiveTramoUseCase: getIt<GetActiveTramoUseCase>(),
      updateTramoStatusUseCase: getIt<UpdateTramoStatusUseCase>(),
    ),
  );
}
