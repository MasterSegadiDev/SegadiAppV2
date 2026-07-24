import '../../features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import '../../features/user_profile/data/datasources/user_profile_remote_datasource_impl.dart';
import '../../features/user_profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/user_profile/domain/repositories/user_profile_repository.dart';
import '../../features/user_profile/domain/use_cases/get_user_profile_usecase.dart';

import 'injection_container.dart';

Future<void> setupUserProfileDependencies() async {
  //==========================
  // Datasources
  //==========================

  getIt.registerLazySingleton<UserProfileRemoteDatasource>(
    () => UserProfileRemoteDatasourceImpl(),
  );

  //==========================
  // Repositories
  //==========================

  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      getIt<UserProfileRemoteDatasource>(),
    ),
  );

  //==========================
  // UseCases
  //==========================

  getIt.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(
      getIt<UserProfileRepository>(),
    ),
  );
}
