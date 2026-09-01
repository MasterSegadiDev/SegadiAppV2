import 'package:segadi/features/evidence/domain/entities/delivery_evidence.dart';
import 'package:segadi/features/evidence/domain/repositories/evidence_repository.dart';

class SendDeliveryEvidencesUseCase {
  final EvidenceRepository deliveryEvidenceRepository;

  SendDeliveryEvidencesUseCase(
    this.deliveryEvidenceRepository,
  );

  Future<bool> call(
    DeliveryEvidence deliveryEvidences,
  ) {
    return deliveryEvidenceRepository.sendDeliveryEvidences(deliveryEvidences);
  }
}
