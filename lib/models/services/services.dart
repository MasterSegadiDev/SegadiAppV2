import 'dart:convert';

import 'package:segadi/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

List<Services> servicesFromJson(String str) =>
    List<Services>.from(json.decode(str).map((x) => Services.fromJson(x)));

String servicesToJson(List<Services> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Services {
  int? id;
  String? service;
  String? client;
  String? origin;
  String? destination;
  String? loadDate;
  String? unloadDate;
  String? documenter;
  String? status;
  String? scaleOne;
  String? scaleTwo;

  Services({
    this.id,
    this.service,
    this.client,
    this.origin,
    this.destination,
    this.loadDate,
    this.unloadDate,
    this.documenter,
    this.status,
    this.scaleOne,
    this.scaleTwo,
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
      scaleOne: json["stopover_1"],
      scaleTwo: json["stopover_2"]);

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
        "stopover_1": scaleOne,
        "stopover_2": scaleTwo,
      };

  final String baseUrl = GlobalVariables.baseUrl;
  final Map<String, String> headers = GlobalVariables.headers;

  Future<List<Services>> fetchItems() async {
    late int id;
    late String? token;
    List<Services> services = [];

    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id') ?? 0;
    token = prefs.getString('token');
    var route = 'index.php';

    var response = await http.get(
      Uri.parse(baseUrl + route).replace(
        queryParameters: {
          'r': 'esegadi/getactivas',
          'id': id.toString(),
          'token': token,
        },
      ),
    );
    print('ESTATUS DEL LISTADO SERVICIOS:' + response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Services.fromJson(json)).toList();
    } else {
      return services;
    }
  }
}
