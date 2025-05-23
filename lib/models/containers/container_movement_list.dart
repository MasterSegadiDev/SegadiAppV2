// To parse this JSON data, do
//
//     final containerMovement = containerMovementFromJson(jsonString);

import 'dart:convert';

List<ContainerMovement> containerMovementFromJson(String str) =>
    List<ContainerMovement>.from(
        json.decode(str).map((x) => ContainerMovement.fromJson(x)));

String containerMovementToJson(List<ContainerMovement> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ContainerMovement {
  int id;
  String? craneMovement;
  dynamic craneOperator;
  String? movementType;
  String? service;
  dynamic containerNumberA;
  dynamic containerNumberB;
  String? containerToMove;
  String? containerStatus;
  String? containerMovementOperator;
  String? unit;
  String? containerLocationId;
  dynamic localOperator;
  dynamic localUnit;
  String? status;
  String? comments;

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
      );

  get areaDestino => null;

  get espacioDestino => null;

  get nivelDestino => null;

  Map<String, dynamic> toJson() => {
        "id": id,
        "crane_movement": craneMovement,
        "crane_operator": craneOperator,
        "movement_type": movementType,
        "service": service,
        "container_number_a": containerNumberA,
        "container_number_b": containerNumberB,
        "container_to_move": containerToMove,
        "container_status": containerStatus,
        "operator": containerMovementOperator,
        "unit": unit,
        "container_location_id": containerLocationId,
        "local_operator": localOperator,
        "local_unit": localUnit,
        "status": status,
        "comments": comments,
      };
}
