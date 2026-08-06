import 'package:segadi/features/services/domain/entities/services_status_entity.dart';

import 'recipient_entity.dart';
import 'sender_entity.dart';
import 'service_actions_entity.dart';

class ServiceDetailEntity {
  final SenderEntity sender;
  final RecipientEntity recipient;
  final ServiceActionsEntity actions;
  // final ServiceStatusEntity status;

  const ServiceDetailEntity({
    required this.sender,
    required this.recipient,
    required this.actions,
    // required this.status,
  });
}
