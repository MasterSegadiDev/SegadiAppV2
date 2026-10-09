import 'package:segadi/features/evidence_eir/data/models/delivery_evidence_eir_model.dart';

abstract class EvidenceEirRemoteDatasource {
  Future<bool> sendDeliveryEvidencesEir(
    DeliveryEvidenceEirModel evidence,
  );
}
