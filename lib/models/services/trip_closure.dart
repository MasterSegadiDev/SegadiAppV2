import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:segadi/utils/global_variables.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        // OJO: imagen no se puede construir directamente desde json en este modelo
        closeTravel: json["service_closed"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "service_id": serviceId,
        "extension": extension,
        // No serializamos la imagen directamente
        "service_closed": closeTravel,
      };

  final String baseUrl = GlobalVariables.baseUrl;
  final Map<String, String> headers = GlobalVariables.headers;

  // Inserta una imagen como evidencia para cierre de viaje
  Future<http.Response> insertImageTripClosure(
      int id, String serviceId, String imageBase64, String extension) async {
    final token = await LoginViewModel.getSavedToken();

    if (token == null) {
      throw Exception("Token no disponible");
    }

    final Map<String, dynamic> data = {
      "service_id": id,
      "token": token,
      "document_name": "$serviceId$extension",
      "document_description": "Evidencia Operador",
      "document_type": "POD Operador",
      "document": imageBase64,
    };

    final url = Uri.parse('${baseUrl}index.php?r=esegadi/evidenciaspost');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Error al guardar la evidencia (status: ${response.statusCode})');
    }

    return response;
  }

  // Obtiene el total de evidencias pendientes para un servicio
  Future<int> getTotalEvidentias(int serviceId) async {
    final token = await LoginViewModel.getSavedToken();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id') ?? 0;

    if (token == null) {
      throw Exception('Token no disponible');
    }

    final uri = Uri.parse('${baseUrl}index.php').replace(queryParameters: {
      'r': 'esegadi/getevidenciasfaltantes',
      'token': token,
      'id': userId.toString(),
      'service_id': serviceId.toString(),
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final remaining = data['remaining_evidences'];
      return remaining is int ? remaining : int.parse(remaining.toString());
    } else {
      throw Exception(
          'Error al consultar las evidencias (status: ${response.statusCode})');
    }
  }

  // Cierra el viaje enviando la solicitud correspondiente
  Future<http.Response> closeTravels(int serviceId) async {
    final token = await LoginViewModel.getSavedToken();

    if (token == null) {
      throw Exception("Token no disponible");
    }

    final Map<String, dynamic> data = {
      "service_id": serviceId,
      "token": token,
      "close": 1,
    };

    final url = Uri.parse('${baseUrl}index.php?r=esegadi/cierreevidenciaspost');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Error al cerrar el viaje (status: ${response.statusCode})');
    }

    return response;
  }
}
