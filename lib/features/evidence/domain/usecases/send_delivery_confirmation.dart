import 'package:segadi/features/evidence/domain/entities/delivery_confirmation.dart';
import 'package:segadi/features/evidence/domain/repositories/evidence_repository.dart';

class SendDeliveryConfirmationUseCase {
  final EvidenceRepository deliveryConfirmationEvidenceRepository;

  SendDeliveryConfirmationUseCase(
    this.deliveryConfirmationEvidenceRepository,
  );

  Future<bool> call(
    DeliveryConfirmation confirmation,
  ) {
    return deliveryConfirmationEvidenceRepository
        .sendDeliveryConfirmation(confirmation);
  }
}
