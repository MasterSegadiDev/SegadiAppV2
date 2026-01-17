import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:segadi/models/containers/container_movements.dart';
import 'package:segadi/utils/global_variables.dart';

class Ubicacion {
  final String id;
  final String area;
  final String espacio;
  final String nivel;
  final String codigo;
  String? color;
  String estado;
  String? numberSerie;

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
        espacio: json['espacio_contenedor'] ?? " ",
        nivel: json['ubicacion_contenedor'].split('-').last, // Ej: "1"
        codigo: json['ubicacion_contenedor'],
        color: json['color'],
        //estatus: json['estatus'],
        estado: json['estatus'] ?? '',
        numberSerie: json['container_number'] ?? '');
  }
}

class UbicationMovement {
  final Map<String, String> headers = GlobalVariables.headers;
  Future<http.Response> saveMovement(Movimiento movimiento) async {
    final String baseUrl = GlobalVariables.baseUrl;

    // Preparar cuerpo del request
    var body = json.encode(movimiento.toJson()); // Asegúrate de tener toJson()
    var url = Uri.parse('${baseUrl}index.php?r=esegadi/movimientosgruapost');

    print('Enviando movimiento:');
    //print(body);

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    //print('Status code: ${response.statusCode}');
    // print('Response body: ${response.body}');

    return response;
  }
}
