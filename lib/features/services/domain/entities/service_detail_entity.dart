import 'package:segadi/features/services/domain/entities/detail_service_actions_entity.dart';

import 'recipient_entity.dart';
import 'sender_entity.dart';

class ServiceDetailEntity {
  final SenderEntity sender;
  final RecipientEntity recipient;
  final ServiceActionsEntity actions;

  const ServiceDetailEntity({
    required this.sender,
    required this.recipient,
    required this.actions,
  });
}
