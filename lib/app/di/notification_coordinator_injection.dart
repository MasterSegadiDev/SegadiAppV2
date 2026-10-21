import 'package:get_it/get_it.dart';

import 'package:segadi/core/device/notifications/notification_service.dart';
import 'package:segadi/features/notifications/aplication/notification_coordinator.dart';
import 'package:segadi/features/notifications/aplication/referral_notification_resolver.dart';
import 'package:segadi/features/notifications/domain/entities/push_notification_event.dart';
import 'package:segadi/features/services/domain/usecases/get_assigned_services_usecase.dart';

void setupNotificationResolverDependencies() {
  final getIt = GetIt.instance;

  if (!getIt.isRegistered<ReferralNotificationResolver>()) {
    getIt.registerLazySingleton<ReferralNotificationResolver>(
      () => ReferralNotificationResolver(
        getIt<GetAssignedServicesUseCase>(),
      ),
    );
  }
}

void setupNotificationCoordinatorDependencies({
  required void Function(PushNotificationEvent) onNotificationTap,
}) {
  final getIt = GetIt.instance;

  if (!getIt.isRegistered<NotificationCoordinator>()) {
    getIt.registerLazySingleton<NotificationCoordinator>(
      () => NotificationCoordinator(
        notificationService: getIt<NotificationService>(),
        onNotificationTap: onNotificationTap,
      ),
    );
  }
}
