import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource_impl.dart';

import '../../features/auth/data/datasources/refresh_remote_datasource.dart';
import '../../features/auth/data/datasources/refresh_remote_datasource_impl.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/refresh_repository_impl.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/refresh_repository.dart';

import '../../features/auth/domain/use_cases/login_usecase.dart';
import '../../features/auth/domain/use_cases/refresh_token_usecase.dart';

import 'package:segadi/core/services/permissions/permission_service.dart';
import 'package:segadi/core/services/permissions/permission_service_impl.dart';

import 'injection_container.dart';

Future<void> setupAuthDependencies() async {
  //==========================
  // Datasources
  //==========================

  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(),
  );

  getIt.registerLazySingleton<RefreshRemoteDatasource>(
    () => RefreshRemoteDatasourceImpl(),
  );

  //==========================
  // Repositories
  //==========================

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDatasource>(),
    ),
  );

  getIt.registerLazySingleton<RefreshRepository>(
    () => RefreshRepositoryImpl(
      getIt<RefreshRemoteDatasource>(),
    ),
  );

  //==========================
  // UseCases
  //==========================

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(
      getIt<AuthRepository>(),
    ),
  );

  getIt.registerLazySingleton<RefreshTokenUseCase>(
    () => RefreshTokenUseCase(
      getIt<RefreshRepository>(),
    ),
  );

  //========================
  //PermissionsServices
  //========================

  getIt.registerLazySingleton<PermissionService>(
    () => PermissionServiceImpl(),
  );
}
