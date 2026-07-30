import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:segadi/core/connectivity/connectivity_service.dart';
import 'package:segadi/core/storage/secure_storage_service.dart';
import '../../core/permissions/permission_service.dart';
import 'injection_container.dart';

Future<void> setupCoreDependencies() async {
  getIt.registerLazySingleton<Connectivity>(
    () => Connectivity(),
  );

  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );

  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  getIt.registerLazySingleton<PermissionService>(
    () => PermissionService(),
  );
}
