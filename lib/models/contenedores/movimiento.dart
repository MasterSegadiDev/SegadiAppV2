class Movimiento {
  final int? crane_movement_id;
  final String movement_type;
  final String crane_operator_id;

  final int? container_location_id;
  final String? new_container_location_id;

  final String? container_number;
  final String? status;
  final String token;

  final String weight;
  final String document_name;
  final String document;
  final String site_id;

  Movimiento({
    required this.movement_type,
    required this.crane_operator_id,
    required this.token,
    required this.site_id,
    this.crane_movement_id,
    this.container_location_id,
    this.new_container_location_id,
    this.container_number,
    this.status,
    this.weight = '',
    this.document_name = '',
    this.document = '',
  });

  Map<String, dynamic> toJson() => {
        "crane_movement": crane_movement_id,
        "movement_type": movement_type,
        "crane_operator_id": crane_operator_id,
        "container_location_id": container_location_id,
        "new_container_location_id": new_container_location_id,
        "container_number": container_number,
        "status": status,
        "token": token,
        "weight": weight,
        "document_name": document_name,
        "document": document,
        "site_id": site_id,
      };
}
