// To parse this JSON data, do
//
//     final services = servicesFromJson(jsonString);

import 'dart:convert';

List<Services> servicesFromJson(String str) =>
    List<Services>.from(json.decode(str).map((x) => Services.fromJson(x)));

String servicesToJson(List<Services> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Services {
  final int id;
  final String service;
  final String client;
  final String origin;
  final String destination;
  final String loadDate;
  final String unloadDate;
  final String documenter;

  Services({
    required this.id,
    required this.service,
    required this.client,
    required this.origin,
    required this.destination,
    required this.loadDate,
    required this.unloadDate,
    required this.documenter,
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
      };
}
