class Movimiento {
  final int? crane_movement_id;
  final String? movement_type;
  final String? crane_operator_id;
  final int? container_location_id;
  final String? container_number;
  final String? new_container_location_id;
  final String? status;
  final String token;
  final String weight;
  final String document_name;
  final String document;
  final int? service_id;
  final String site_id;

  Movimiento({
    this.crane_movement_id,
    this.movement_type,
    this.crane_operator_id,
    this.container_location_id,
    this.container_number,
    this.new_container_location_id,
    this.status,
    required this.token,
    required this.weight,
    required this.document_name,
    required this.document,
    this.service_id,
    required this.site_id,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      crane_movement_id: json['crane_movement_id'] ?? '',
      movement_type: json['movement_type'] ?? '',
      crane_operator_id: json['crane_operator_id'] ?? '',
      container_location_id: json['container_location_id'] ?? '',
      container_number: json['container_number'],
      new_container_location_id: json['new_container_location_id'] ?? '',
      status: json['status'] ?? '',
      token: json['token'] ?? '',
      weight: json['weight'] ?? '',
      document_name: json['document_name'] ?? '',
      document: json['document'] ?? '',
      service_id: json['service_id'],
      site_id: json['site_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crane_movement_id': crane_movement_id,
      'movement_type': movement_type,
      'crane_operator_id': crane_operator_id,
      'container_location_id': container_location_id,
      'container_number': container_number,
      'new_container_location_id': new_container_location_id,
      'status': status,
      'token': token,
      'weight': weight,
      'document_name': document_name,
      'document': document,
      'service_id': service_id,
      'site_id': site_id,
    };
  }
}
