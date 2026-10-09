import 'package:segadi/features/evidence_eir/domain/entities/delivery_evidence_eir.dart';

abstract class EvidenceEirRepository {
  Future<bool> sendDeliveryEvidencesEir(
    DeliveryEvidenceEir evidence,
  );
}
