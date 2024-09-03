import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

class ItemService {
  final storage = const FlutterSecureStorage();

  Future<List<Services>> fetchItems() async {
    late int id;
    late String? token;
    List<Services> services = [];

    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id') ?? 0;
    token = await storage.read(key: 'token');
    var route = 'index.php';

    var response = await http.get(
      Uri.parse(baseURL + route).replace(
        queryParameters: {
          'r': 'esegadi/getactivas',
          'id': id.toString(),
          'token': token,
        },
      ),
    );

    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in data) {
        services.add(Services.fromJson(index));
      }

      return services;
    } else {
      return services;
    }
  }
}
