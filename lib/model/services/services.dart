// To parse this JSON data, do
//
//     final services = servicesFromJson(jsonString);

import 'dart:convert';

List<Services> servicesFromJson(String str) =>
    List<Services>.from(json.decode(str).map((x) => Services.fromJson(x)));

String servicesToJson(List<Services> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Services {
  int id;
  String service;
  String client;
  String origin;
  String destination;
  String loadDate;
  String unloadDate;
  String documenter;
  String? status;

  Services({
    required this.id,
    required this.service,
    required this.client,
    required this.origin,
    required this.destination,
    required this.loadDate,
    required this.unloadDate,
    required this.documenter,
    this.status,
  });

  factory Services.fromJson(Map<String, dynamic> json) => Services(
        id: json["id"],
        service: json["service"],
        client: json["client"],
        origin: json["origin"],
        destination: json["destination"],
        loadDate: json["load_date"],
        unloadDate: json["unload_date"],
        documenter: json["documenter"],
        status: json["status"] ?? 'Sin Estatus',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "service": service,
        "client": client,
        "origin": origin,
        "destination": destination,
        "load_date": loadDate,
        "unload_date": unloadDate,
        "documenter": documenter,
        "status": status,
      };
}
