import 'recipient_entity.dart';
import 'sender_entity.dart';

class ServiceDetailEntity {
  final String id;
  final SenderEntity sender;
  final RecipientEntity recipient;

  const ServiceDetailEntity({
    required this.id,
    required this.sender,
    required this.recipient,
  });
}
