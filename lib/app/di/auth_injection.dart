import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/use_cases/login_usecase.dart';
import 'injection_container.dart';

Future<void> setupAuthDependencies() async {
  // Datasource
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDatasource>(),
    ),
  );

  // UseCase
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(
      getIt<AuthRepository>(),
    ),
  );
}
