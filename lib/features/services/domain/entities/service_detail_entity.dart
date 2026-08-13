import 'recipient_entity.dart';
import 'sender_entity.dart';
import 'service_actions_entity.dart';
import 'service_status_entity.dart';
import '../../../support_status/domain/entities/support_status_state_entity.dart';

class ServiceDetailEntity {
  final SenderEntity sender;
  final RecipientEntity recipient;
  final ServiceActionsEntity actions;
  final ServiceStatusEntity status;
  final SupportStatusStateEntity? supportStatus;
  const ServiceDetailEntity({
    required this.sender,
    required this.recipient,
    required this.actions,
    required this.status,
    this.supportStatus,
  });
}
