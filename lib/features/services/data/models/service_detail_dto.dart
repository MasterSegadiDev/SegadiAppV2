import 'package:segadi/features/services/data/dto/recipient_dto.dart';
import 'package:segadi/features/services/data/dto/sender_dto.dart';

import '../../domain/entities/service_detail_entity.dart';

class ServiceDetailDto extends ServiceDetailEntity {
  const ServiceDetailDto({
    required super.sender,
    required super.recipient,
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
    );
  }
}
