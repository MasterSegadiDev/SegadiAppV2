import 'package:segadi/app/di/injection_container.dart';

import '../../core/device/location/location_service.dart';
import '../../core/device/location/location_service_impl.dart';

Future<void> setupLocationDependencies() async {
  if (!getIt.isRegistered<LocationService>()) {
    getIt.registerLazySingleton<LocationService>(
      () => LocationServiceImpl(),
    );
  }
}
