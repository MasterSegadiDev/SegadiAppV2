import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';

class ServiceStatusEntity {
  final bool blnOutgoingFromRecipient;
  final bool enableBtn;
  final String nextMandatoryStatus;
  final String nextMandatoryStatusId;
  final SupportStatusCurrentEntity? supportStatus;

  const ServiceStatusEntity({
    required this.blnOutgoingFromRecipient,
    required this.enableBtn,
    required this.nextMandatoryStatus,
    required this.nextMandatoryStatusId,
    this.supportStatus,
  });

  ServiceStatusEntity copyWith({
    bool? blnOutgoingFromRecipient,
    bool? enableBtn,
    String? nextMandatoryStatus,
    String? nextMandatoryStatusId,
    SupportStatusCurrentEntity? supportStatus,
  }) {
    return ServiceStatusEntity(
      blnOutgoingFromRecipient:
          blnOutgoingFromRecipient ?? this.blnOutgoingFromRecipient,
      enableBtn: enableBtn ?? this.enableBtn,
      nextMandatoryStatus: nextMandatoryStatus ?? this.nextMandatoryStatus,
      nextMandatoryStatusId:
          nextMandatoryStatusId ?? this.nextMandatoryStatusId,
      supportStatus: supportStatus ?? this.supportStatus,
    );
  }
}
