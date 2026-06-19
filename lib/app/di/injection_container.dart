import 'package:get_it/get_it.dart';
import 'package:segadi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:segadi/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:segadi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:segadi/features/auth/domain/repositories/auth_repository.dart';
import 'package:segadi/features/auth/domain/use_cases/login_usecase.dart';

final getIt = GetIt.instance;
Future<void> setupDependencies() async {
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
