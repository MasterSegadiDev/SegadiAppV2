abstract class NotificationService {
  Future<void> initialize({
    void Function(String? payload)? onNotificationTap,
  });

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  });
}
