import 'package:segadi/features/services/domain/entities/service_status_entity.dart';
import 'package:segadi/features/support_status/domain/entities/support_status_state_entity.dart';

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
          : SupportStatusStateEntity(
              active: supportStatusJson['active'] == true,
              status: supportStatusJson['status']?.toString(),
              statusName: supportStatusJson['statusName']?.toString(),
              startedAt: _parseDateTime(
                supportStatusJson['startedAt'],
              ),
            ),
    );
  }

  static DateTime? _parseDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final valueString = value.toString();

    if (valueString.isEmpty) {
      return null;
    }

    return DateTime.tryParse(
      valueString,
    );
  }
}
