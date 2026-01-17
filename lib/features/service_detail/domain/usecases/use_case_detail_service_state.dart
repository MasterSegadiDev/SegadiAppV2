import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_state.dart';

DetailServiceState buildDetailServiceState(DetailServiceEntity e) {
  final bool mustSendEvidence =
      e.nextMandatoryStatusId == 10 && e.isEvidence == false;

  /// 🔹 Si debe enviar evidencia → NO mostrar botón
  final bool enableButton = !mustSendEvidence &&
      e.nextMandatoryStatusId != 0 &&
      e.nextMandatoryStatus.isNotEmpty;

  /// 🔹 Texto del botón
  final String buttonLabel = mustSendEvidence
      ? 'Enviar evidencia'
      : (e.nextMandatoryStatus.isNotEmpty
          ? e.nextMandatoryStatus
          : e.mandatoryStatus);

  return DetailServiceState(
    entity: e,
    enableButton: enableButton,
    buttonLabel: buttonLabel,
    mustSendEvidence: mustSendEvidence, // ⬅️ NUEVO
  );
}
