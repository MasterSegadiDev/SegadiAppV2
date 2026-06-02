import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_state.dart';

DetailServiceState buildDetailServiceState(DetailServiceEntity e) {
  // 1. Detectamos si es el flujo obligatorio de evidencias (Segadi Flow)
  final bool mustSendEvidence =
      e.nextMandatoryStatusId == 10 && e.isEvidence == false;

  final bool enableButton = mustSendEvidence ? false : e.ui.enableBtn;

  /// 🔹 Texto del botón
  /// Si falta evidencia, le ponemos un texto informativo de lo que está pasando.
  final String buttonLabel = mustSendEvidence
      ? 'Esperando evidencias...' // O el nombre del estatus actual
      : (e.nextMandatoryStatus.isNotEmpty
          ? e.nextMandatoryStatus
          : e.mandatoryStatus);

  return DetailServiceState(
    entity: e,
    enableButton: enableButton,
    buttonLabel: buttonLabel,
    mustSendEvidence: mustSendEvidence,
  );
}
