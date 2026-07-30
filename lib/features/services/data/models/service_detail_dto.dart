import 'package:segadi/features/services/data/dto/recipient_dto.dart';
import 'package:segadi/features/services/data/dto/sender_dto.dart';
import 'package:segadi/features/services/data/models/service_actions_model.dart';

import '../../domain/entities/service_detail_entity.dart';

class ServiceDetailDto extends ServiceDetailEntity {
  const ServiceDetailDto({
    required super.sender,
    required super.recipient,
    required super.actions,
  });

  factory ServiceDetailDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceDetailDto(
      sender: SenderDto.fromJson(
        json['remitente'] ?? {},
      ),
      recipient: RecipientDto.fromJson(
        json['destinatario'] ?? {},
      ),
      actions: json['acciones'] != null
          ? ServiceActionsModel.fromJson(
              json['acciones'],
            )
          : const ServiceActionsModel.empty(),
    );
  }
}
