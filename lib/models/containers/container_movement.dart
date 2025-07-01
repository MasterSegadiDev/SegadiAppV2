import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:segadi/models/containers/container_movements.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/utils/global_variables.dart';

class Ubicacion {
  final String id;
  final String area;
  final String espacio;
  final String nivel;
  final String codigo;
  final String? color;
  final String estado;
  final String? numberSerie;

  Ubicacion({
    required this.id,
    required this.area,
    required this.espacio,
    required this.nivel,
    required this.codigo,
    this.color,
    required this.estado,
    this.numberSerie,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
        id: json['id'],
        area: json['area_contenedor'],
        espacio: json['espacio_contenedor'],
        nivel: json['ubicacion_contenedor'].split('-').last, // Ej: "1"
        codigo: json['ubicacion_contenedor'],
        color: json['color'],
        //estatus: json['estatus'],
        estado: json['estatus'] ?? '',
        numberSerie: json['container_number'] ?? 'N/A');
  }
}

class UbicationMovement {
  final Map<String, String> headers = GlobalVariables.headers;
  Future<http.Response> saveMovement(Movimiento movimiento) async {
    final String baseUrl = GlobalVariables.baseUrl;

    var body = json.encode(movimiento);
    var url = Uri.parse('${baseUrl}index.php?r=esegadi/movimientosgruapost');

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  }
}
