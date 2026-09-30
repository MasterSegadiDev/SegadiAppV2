import 'package:segadi/features/services/domain/entities/service_general_entity.dart';
import 'package:segadi/features/services/domain/entities/service_status_entity.dart';
import 'package:segadi/features/services/domain/enums/evidence_step.dart';

class ResolveEvidenceStepUseCase {
  EvidenceStep call({
    required ServiceGeneralEntity service,
    required ServiceStatusEntity status,
  }) {
    if (status.blnOutgoingFromRecipient == true) {
      return EvidenceStep.notApplicable;
    }

    if (!service.blnConfirmation) {
      return EvidenceStep.confirmationPending;
    }

    if (!service.blnEvidence) {
      return EvidenceStep.evidencePending;
    }

    return EvidenceStep.completed;
  }
}
