import 'package:segadi/app/di/injection_container.dart';

import '../../core/device/firebase/firebase_service.dart';
import '../../core/device/firebase/firebase_service_impl.dart';

Future<void> setupFirebaseDependencies() async {
  if (!getIt.isRegistered<FirebaseService>()) {
    getIt.registerLazySingleton<FirebaseService>(
      () => FirebaseServiceImpl(),
    );
  }
}
