import 'package:segadi/features/evidence_eir/domain/entities/delivery_evidence_eir.dart';
import 'package:segadi/features/evidence_eir/domain/repositories/evidence_eir_repository.dart';

class SendEirDeliveryEvidencesUsecase {
  final EvidenceEirRepository deliveryEvidenceEirRepository;

  SendEirDeliveryEvidencesUsecase(
    this.deliveryEvidenceEirRepository,
  );

  Future<bool> call(
    DeliveryEvidenceEir deliveryEvidencesEir,
  ) {
    return deliveryEvidenceEirRepository
        .sendDeliveryEvidencesEir(deliveryEvidencesEir);
  }
}
