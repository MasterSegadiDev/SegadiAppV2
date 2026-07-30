import 'recipient_entity.dart';
import 'sender_entity.dart';

class ServiceDetailEntity {
  final SenderEntity sender;
  final RecipientEntity recipient;

  const ServiceDetailEntity({
    required this.sender,
    required this.recipient,
  });
}
