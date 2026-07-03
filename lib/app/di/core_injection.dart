import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:segadi/core/contracts/network_info.dart';
import 'package:segadi/core/network/connectivity_service.dart';
import 'injection_container.dart';

Future<void> setupCoreDependencies() async {
  getIt.registerLazySingleton<Connectivity>(
    () => Connectivity(),
  );

  getIt.registerLazySingleton<NetworkInfo>(
    () => ConnectivityService(
      getIt<Connectivity>(),
    ),
  );
}
