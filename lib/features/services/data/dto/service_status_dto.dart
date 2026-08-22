import 'package:segadi/features/services/domain/entities/service_status_entity.dart';
import 'package:segadi/features/services/domain/entities/support_status_current_entity.dart';

class ServiceStatusDto extends ServiceStatusEntity {
  const ServiceStatusDto({
    required super.enableBtn,
    required super.nextMandatoryStatus,
    required super.nextMandatoryStatusId,
    super.supportStatus,
  });

  factory ServiceStatusDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final supportStatusJson = json['supportStatus'] as Map<String, dynamic>?;

    return ServiceStatusDto(
      enableBtn: json['enableBtn'] == true,
      nextMandatoryStatus: json['nextMandatoryStatus']?.toString() ?? '',
      nextMandatoryStatusId: json['nextMandatoryStatusId']?.toString() ?? '',
      supportStatus: supportStatusJson == null
          ? null
          : SupportStatusCurrentEntity(
              id: supportStatusJson['_id']?.toString() ?? '',
              active: supportStatusJson['active'] == true,
              startedAt: supportStatusJson['startedAt']?.toString() ?? '',
              status: supportStatusJson['status']?.toString() ?? '',
              statusName: supportStatusJson['statusName']?.toString() ?? '',
            ),
    );
  }
}
