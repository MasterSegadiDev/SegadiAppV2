class ContainerMovement {
  final int id;
  final String? craneMovement;
  final dynamic craneOperator;
  final String? movementType;
  final String? service;
  final dynamic containerNumberA;
  final dynamic containerNumberB;
  final String? containerToMove;
  final String? containerStatus;
  final String? containerMovementOperator;
  final String? unit;
  final String? containerLocationId;
  final dynamic localOperator;
  final dynamic localUnit;
  final String? status;
  final String? comments;

  final String? area;
  final String? space;
  final String? level;

  ContainerMovement({
    required this.id,
    required this.craneMovement,
    required this.craneOperator,
    required this.movementType,
    required this.service,
    required this.containerNumberA,
    required this.containerNumberB,
    required this.containerToMove,
    required this.containerStatus,
    required this.containerMovementOperator,
    required this.unit,
    required this.containerLocationId,
    required this.localOperator,
    required this.localUnit,
    required this.status,
    required this.comments,
    this.area,
    this.space,
    this.level,
  });

  factory ContainerMovement.fromJson(Map<String, dynamic> json) =>
      ContainerMovement(
        id: json["id"],
        craneMovement: json["crane_movement"],
        craneOperator: json["crane_operator"],
        movementType: json["movement_type"],
        service: json["service"],
        containerNumberA: json["container_number_a"],
        containerNumberB: json["container_number_b"],
        containerToMove: json["container_to_move"],
        containerStatus: json["container_status"],
        containerMovementOperator: json["operator"],
        unit: json["unit"],
        containerLocationId: json["container_location_id"],
        localOperator: json["local_operator"],
        localUnit: json["local_unit"],
        status: json["status"],
        comments: json["comments"],
        area: json['area'],
        space: json['space'],
        level: json['level'],
      );
}
