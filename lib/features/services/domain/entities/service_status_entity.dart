import 'package:segadi/features/support_status/domain/entities/support_status_state_entity.dart';

class ServiceStatusEntity {
  final bool enableBtn;
  final String nextMandatoryStatus;
  final String nextMandatoryStatusId;
  final SupportStatusStateEntity? supportStatus;

  const ServiceStatusEntity({
    required this.enableBtn,
    required this.nextMandatoryStatus,
    required this.nextMandatoryStatusId,
    this.supportStatus,
  });
}
