import '../../domain/entities/delivery_evidence.dart';

class DeliveryEvidenceModel extends DeliveryEvidence {
  const DeliveryEvidenceModel({
    required super.serviceRequestId,
    super.evidence1,
    super.evidence2,
    super.evidence3,
    super.evidence4,
    super.evidence5,
    required super.notes,
    required super.referralId,
  });

  factory DeliveryEvidenceModel.fromEntity(
    DeliveryEvidence entity,
  ) {
    return DeliveryEvidenceModel(
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
