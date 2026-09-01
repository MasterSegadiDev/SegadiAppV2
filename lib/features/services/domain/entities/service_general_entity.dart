import 'package:segadi/features/services/domain/entities/recipient_entity.dart';
import 'package:segadi/features/services/domain/entities/sender_entity.dart';

class ServiceGeneralEntity {
  final bool blnConfirmation;
  final bool blnEvidence;
  final String id;
  final SenderEntity sender;
  final RecipientEntity recipient;
  final String serviceType;

  const ServiceGeneralEntity({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.serviceType,
    required this.blnConfirmation,
    required this.blnEvidence,
  });
}
