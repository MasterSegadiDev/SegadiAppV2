import '../../domain/entities/sender_entity.dart';

class SenderDto extends SenderEntity {
  const SenderDto({
    required super.name,
    required super.phone,
    required super.directContact,
    required super.address,
  });

  factory SenderDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return SenderDto(
      name: json['nombre'] ?? '',
      phone: json['numero_telefono'] ?? '',
      directContact: json['contacto_directo'] ?? '',
      address: json['direccion_completa'] ?? '',
    );
  }
}
