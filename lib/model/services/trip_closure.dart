import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/view_model/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<TripClosure> tripClosureFromJson(String str) => List<TripClosure>.from(
    json.decode(str).map((x) => TripClosure.fromJson(x)));

String tripClosureToJson(List<TripClosure> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TripClosure {
  int? id;
  String? serviceId;
  String? extension;
  File? image;
  bool? closeTravel;

  TripClosure({
    this.id,
    this.serviceId,
    this.extension,
    this.image,
    this.closeTravel,
  });

  factory TripClosure.fromJson(Map<String, dynamic> json) => TripClosure(
      id: json["id"],
      serviceId: json["service_id"],
      extension: json["extension"],
      image: json["image"],
      closeTravel: json["service_closed"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "service_id": serviceId,
        "extension": extension,
        "image": image,
        "service_closed": closeTravel
      };

  final storage = const FlutterSecureStorage();
  Future<http.Response> insertImage(
      int id, String serviceId, String image, String extension) async {
    late String? token;

    token = await storage.read(key: 'token');

    Map data = {
      "service_id": id,
      "token": token,
      "document_name": serviceId + extension,
      "document_description": "Evidencia Operador",
      "document_type": "POD Operador",
      "document": image,
    };

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/evidenciaspost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Ha ocurriod un error al guardar la evidencia');
    }
  }

  Future getTotalEvidentias(int serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    late String? token;

    token = await storage.read(key: 'token');
    var userId = prefs.getInt('id') ?? 0;
    var route = 'index.php';

    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getevidenciasfaltantes',
      'token': token,
      'id': userId.toString(),
      'service_id': serviceId.toString(),
    }));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      return data['remaining_evidences'];
    } else {
      throw Exception('Ha ocurrido un error al consultar las evidencias');
    }
  }

  Future<http.Response> insertImageTripClosure(
      int id, String serviceId, String image, String extension) async {
    late String? token;
    token = await storage.read(key: 'token');

    Map data = {
      "service_id": id,
      "token": token,
      "document_name": serviceId + extension,
      "document_description": "Evidencia Operador",
      "document_type": "POD Operador",
      "document": image,
    };

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/evidenciaspost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Ha ocurrido un error al guardar la evidencia');
    }
  }

  Future<http.Response> closeTravels(serviceId) async {
    late String? token;
    token = await storage.read(key: 'token');

    Map data = {
      "service_id": serviceId,
      "token": token,
      "close": 1,
    };
    print(data);

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/cierreevidenciaspost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Ha ocurrido un error al cerrar el viaje');
    }
  }
}
