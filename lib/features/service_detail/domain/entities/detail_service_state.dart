import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';

class DetailServiceState {
  final DetailServiceEntity entity;
  final bool enableButton;
  final String buttonLabel;
  final bool mustSendEvidence;

  const DetailServiceState({
    required this.entity,
    required this.enableButton,
    required this.buttonLabel,
    required this.mustSendEvidence,
  });
}
