import 'package:get_it/get_it.dart';
import 'package:segadi/features/georuta/data/datasources/georoute_remote_datasource.dart';
import 'package:segadi/features/georuta/data/datasources/georoute_remote_datasource_impl.dart';
import 'package:segadi/features/georuta/data/repositories/georoute_depository_impl.dart';
import 'package:segadi/features/georuta/domain/repositories/georoute_repository.dart';
import 'package:segadi/features/georuta/domain/usecases/get_geofences_usecase.dart';
import 'package:segadi/features/georuta/presentation/viewmodels/georoute_viewmodel.dart';

Future<void> setupGeorouteDependencies(
  GetIt getIt,
) async {
  getIt.registerLazySingleton<GeorouteRemoteDatasource>(
    () => GeorouteRemoteDatasourceImpl(
      dio: getIt(),
    ),
  );

  getIt.registerLazySingleton<GeorouteRepository>(
    () => GeorouteRepositoryImpl(
      remoteDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<GetGeofencesUseCase>(
    () => GetGeofencesUseCase(
      getIt(),
    ),
  );

  getIt.registerFactory<GeorouteViewModel>(
    () => GeorouteViewModel(
      getGeofencesUseCase: getIt(),
    ),
  );
}
