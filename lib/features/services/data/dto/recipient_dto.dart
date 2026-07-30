import '../../domain/entities/recipient_entity.dart';

class RecipientDto extends RecipientEntity {
  const RecipientDto({
    required super.name,
    required super.phone,
    required super.directContact,
    required super.address,
  });

  factory RecipientDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecipientDto(
      name: json['nombre'] ?? '',
      phone: json['numero_telefono'] ?? '',
      directContact: json['contacto_directo'] ?? '',
      address: json['direccion_completa'] ?? '',
    );
  }
}
