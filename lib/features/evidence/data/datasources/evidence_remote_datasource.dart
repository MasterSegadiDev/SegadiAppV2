import 'package:segadi/features/evidence/data/models/delivery_confirmation_model.dart';
import 'package:segadi/features/evidence/data/models/delivery_evidence_model.dart';

abstract class EvidenceRemoteDatasource {
  Future<bool> sendDeliveryConfirmation(
    DeliveryConfirmationModel confirmation,
  );

  Future<bool> sendDeliveryEvidences(
    DeliveryEvidenceModel evidence,
  );
}
