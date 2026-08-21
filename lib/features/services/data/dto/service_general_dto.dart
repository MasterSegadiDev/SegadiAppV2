import '../../domain/entities/service_general_entity.dart';
import '../dto/recipient_dto.dart';
import '../dto/sender_dto.dart';

class ServiceGeneralDto extends ServiceGeneralEntity {
  const ServiceGeneralDto({
    required super.id,
    required super.sender,
    required super.recipient,
    required super.serviceType,
  });

  factory ServiceGeneralDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceGeneralDto(
      id: json['id']?.toString() ?? '',
      sender: SenderDto.fromJson(
        json['remitente'] ?? {},
      ),
      recipient: RecipientDto.fromJson(
        json['destinatario'] ?? {},
      ),
      serviceType: json['serviceType']?.toString() ?? '',
    );
  }
}
