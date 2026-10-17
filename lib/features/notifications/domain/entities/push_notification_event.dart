import 'dart:convert';

enum PushNotificationType {
  referralAssigned,
  referralUpdated,
}

class PushNotificationEvent {
  final PushNotificationType type;
  final String referralId;

  const PushNotificationEvent({
    required this.type,
    required this.referralId,
  });

  static PushNotificationEvent? fromData(
    Map<String, dynamic> data,
  ) {
    final type = data['type']?.toString();
    final referralId = data['referral']?.toString();

    if (referralId == null || referralId.isEmpty) {
      return null;
    }

    switch (type) {
      case 'referral_assigned':
        return PushNotificationEvent(
          type: PushNotificationType.referralAssigned,
          referralId: referralId,
        );

      case 'referral_updated':
        return PushNotificationEvent(
          type: PushNotificationType.referralUpdated,
          referralId: referralId,
        );

      default:
        return null;
    }
  }

  String toPayload() {
    return jsonEncode({
      'type': switch (type) {
        PushNotificationType.referralAssigned => 'referral_assigned',
        PushNotificationType.referralUpdated => 'referral_updated',
      },
      'referral': referralId,
    });
  }

  static PushNotificationEvent? fromPayload(
    String? payload,
  ) {
    if (payload == null || payload.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return fromData(decoded);
    } catch (_) {
      return null;
    }
  }
}
