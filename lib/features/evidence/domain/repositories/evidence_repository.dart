import 'package:segadi/features/evidence/domain/entities/delivery_confirmation.dart';
import 'package:segadi/features/evidence/domain/entities/delivery_evidence.dart';

abstract class EvidenceRepository {
  Future<bool> sendDeliveryConfirmation(
    DeliveryConfirmation confirmation,
  );

  Future<bool> sendDeliveryEvidences(
    DeliveryEvidence evidence,
  );
}
