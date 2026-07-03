// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:get_it/get_it.dart';
// import 'package:segadi/core/contracts/network_info.dart';
// import 'package:segadi/core/network/connectivity_service.dart';
// import 'package:segadi/features/auth/data/datasources/auth_remote_datasource.dart';
// import 'package:segadi/features/auth/data/datasources/auth_remote_datasource_impl.dart';
// import 'package:segadi/features/auth/data/repositories/auth_repository_impl.dart';
// import 'package:segadi/features/auth/domain/repositories/auth_repository.dart';
// import 'package:segadi/features/auth/domain/use_cases/login_usecase.dart';

// final getIt = GetIt.instance;
// Future<void> setupDependencies() async {
//   getIt.registerLazySingleton<Connectivity>(
//     () => Connectivity(),
//   );

//   getIt.registerLazySingleton<NetworkInfo>(
//     () => ConnectivityService(
//       getIt<Connectivity>(),
//     ),
//   );
// Datasource

// getIt.registerLazySingleton<AuthRemoteDatasource>(
//   () => AuthRemoteDatasourceImpl(),
// );

// Repository

// getIt.registerLazySingleton<AuthRepository>(
//   () => AuthRepositoryImpl(
//     getIt<AuthRemoteDatasource>(),
//   ),
// );

// UseCase

// getIt.registerLazySingleton<LoginUseCase>(
//   () => LoginUseCase(
//     getIt<AuthRepository>(),
//   ),
// );

//=================================  secure storage =============================== //
//================================================================================= //

// getIt.registerLazySingleton(
//   () => const FlutterSecureStorage(),
// );

// getIt.registerLazySingleton(
//   () => SecureStorageService.instance,
// );

// getIt.registerLazySingleton(() => SessionManager);
//}

import 'package:get_it/get_it.dart';

import 'auth_injection.dart';
import 'core_injection.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  await setupCoreDependencies();
  await setupAuthDependencies();

  // Futuro
  // await setupLocationDependencies();
  // await setupFirebaseDependencies();
  // await setupNotificationDependencies();
  // await setupCameraDependencies();
  // await setupFilePickerDependencies();
}
