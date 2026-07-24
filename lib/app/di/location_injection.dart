import 'package:segadi/app/di/injection_container.dart';

import '../../core/device/notifications/notification_service.dart';
import '../../core/device/notifications/notification_service_impl.dart';

Future<void> setupLocationDependencies() async {
  if (!getIt.isRegistered<NotificationService>()) {
    getIt.registerLazySingleton<NotificationService>(
      () => NotificationServiceImpl(),
    );
  }
}
