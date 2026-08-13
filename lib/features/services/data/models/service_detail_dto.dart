import 'package:segadi/features/services/data/dto/recipient_dto.dart';
import 'package:segadi/features/services/data/dto/sender_dto.dart';
import 'package:segadi/features/services/domain/entities/service_detail_entity.dart';
import 'package:segadi/features/services/domain/entities/service_status_entity.dart';
import 'package:segadi/features/support_status/domain/entities/support_status_state_entity.dart';

import 'service_actions_model.dart';

class ServiceDetailDto extends ServiceDetailEntity {
  const ServiceDetailDto({
    required super.sender,
    required super.recipient,
    required super.actions,
    required super.status,
    super.supportStatus,
  });

  factory ServiceDetailDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final supportStatusJson = json['supportStatus'] as Map<String, dynamic>?;

    return ServiceDetailDto(
      sender: SenderDto.fromJson(
        json['remitente'] ?? {},
      ),
      recipient: RecipientDto.fromJson(
        json['destinatario'] ?? {},
      ),
      actions: ServiceActionsModel.fromJson(
        json['acciones'] ?? {},
      ),
      status: ServiceStatusEntity(
        mandatoryStatusId: json['mandatoryStatusId']?.toString() ?? '',
        nextMandatoryStatusId: json['nextMandatoryStatusId']?.toString() ?? '',
      ),
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
