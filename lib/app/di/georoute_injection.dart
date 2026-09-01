import 'package:get_it/get_it.dart';
import 'package:segadi/core/device/location/location_service.dart';

import 'package:segadi/features/georuta/data/datasources/georoute_remote_datasource.dart';
import 'package:segadi/features/georuta/data/datasources/georoute_remote_datasource_impl.dart';
import 'package:segadi/features/georuta/data/repositories/georoute_repository_impl.dart';
import 'package:segadi/features/georuta/domain/repositories/georoute_repository.dart';
import 'package:segadi/features/georuta/domain/usecases/get_geofences_usecase.dart';
import 'package:segadi/features/georuta/presentation/viewmodels/georoute_viewmodel.dart';

Future<void> setupGeorouteDependencies(
  GetIt getIt,
) async {
  getIt.registerLazySingleton<GeorouteRemoteDatasource>(
    () => GeorouteRemoteDatasourceImpl(),
  );

  getIt.registerLazySingleton<GeorouteRepository>(
    () => GeorouteRepositoryImpl(
      remoteDataSource: getIt<GeorouteRemoteDatasource>(),
    ),
  );

  getIt.registerLazySingleton<GetGeorouteUseCase>(
    () => GetGeorouteUseCase(
      getIt<GeorouteRepository>(),
    ),
  );

  getIt.registerFactory<GeorouteViewModel>(
    () => GeorouteViewModel(
      getIt<GetGeorouteUseCase>(),
      getIt<LocationService>(),
    ),
  );
}
