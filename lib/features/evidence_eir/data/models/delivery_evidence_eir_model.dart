import 'package:segadi/features/evidence_eir/domain/entities/delivery_evidence_eir.dart';

class DeliveryEvidenceEirModel extends DeliveryEvidenceEir {
  const DeliveryEvidenceEirModel({
    required super.serviceRequestId,
    super.evidence1,
    super.evidence2,
    super.evidence3,
    super.evidence4,
    super.evidence5,
    required super.notes,
    required super.referralId,
  });

  factory DeliveryEvidenceEirModel.fromEntity(
    DeliveryEvidenceEir entity,
  ) {
    return DeliveryEvidenceEirModel(
      serviceRequestId: entity.serviceRequestId,
      evidence1: entity.evidence1,
      evidence2: entity.evidence2,
      evidence3: entity.evidence3,
      evidence4: entity.evidence4,
      evidence5: entity.evidence5,
      notes: entity.notes,
      referralId: entity.referralId,
    );
  }
}
