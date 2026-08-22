import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';

class ServiceStatusEntity {
  final bool enableBtn;
  final String nextMandatoryStatus;
  final String nextMandatoryStatusId;
  final SupportStatusCurrentEntity? supportStatus;

  const ServiceStatusEntity({
    required this.enableBtn,
    required this.nextMandatoryStatus,
    required this.nextMandatoryStatusId,
    this.supportStatus,
  });
}
