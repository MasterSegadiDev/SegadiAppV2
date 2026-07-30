import 'package:segadi/features/services/domain/entities/recipient_entity.dart';
import 'package:segadi/features/services/domain/entities/sender_entity.dart';

class ServiceDetailUi {
  final String serviceNumber;
  final String serviceType;
  final String serviceStatus;

  final SenderEntity sender;
  final RecipientEntity recipient;

  const ServiceDetailUi({
    required this.serviceNumber,
    required this.serviceType,
    required this.serviceStatus,
    required this.sender,
    required this.recipient,
  });
}
