import 'package:segadi/app/di/injection_container.dart';
import 'package:segadi/core/device/firebase/firebase_service.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/features/notifications/aplication/fcm_token_sync_service.dart';
import 'package:segadi/features/notifications/data/datasources/fcm_token_remote_datasource.dart';
import 'package:segadi/features/notifications/data/datasources/fcm_token_remote_datasource_impl.dart';
import 'package:segadi/features/notifications/data/repositories/fcm_token_repository_impl.dart';
import 'package:segadi/features/notifications/domain/repositories/fcm_token_repository.dart';
import 'package:segadi/features/notifications/domain/usecases/register_fcm_token_usecase.dart';

void setupFcmTokenDependencies() {
  getIt.registerLazySingleton<FcmTokenRemoteDatasource>(
    () => FcmTokenRemoteDatasourceImpl(
      dio: DioClient.instance,
    ),
  );

  getIt.registerLazySingleton<FcmTokenRepository>(
    () => FcmTokenRepositoryImpl(
      remoteDatasource: getIt<FcmTokenRemoteDatasource>(),
    ),
  );

  getIt.registerLazySingleton<RegisterFcmTokenUseCase>(
    () => RegisterFcmTokenUseCase(
      firebaseService: getIt<FirebaseService>(),
      repository: getIt<FcmTokenRepository>(),
    ),
  );

  getIt.registerLazySingleton<FcmTokenSyncService>(
    () => FcmTokenSyncService(
      firebaseService: getIt<FirebaseService>(),
      repository: getIt<FcmTokenRepository>(),
    ),
  );
}
