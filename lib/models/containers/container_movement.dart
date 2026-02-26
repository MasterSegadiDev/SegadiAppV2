import 'package:dio/dio.dart';

import 'package:segadi/core/network/api_exceptions.dart';
import 'package:segadi/models/containers/container_movements.dart';

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
  final Dio _dio;

  // Recibimos Dio por constructor para mantener la unificación
  UbicationMovement(this._dio);

  Future<Map<String, dynamic>> saveMovement(Movimiento movimiento) async {
    try {
      // 1. Preparar el cuerpo del request (Dio lo convierte a JSON automáticamente)
      final Map<String, dynamic> data = movimiento.toJson();

      print('Enviando movimiento al servidor...');

      // 2. Realizar la petición POST
      final response = await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/movimientosgruapost'},
        data: data,
      );

      // 3. Dio devuelve por defecto el body ya decodificado en response.data
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // 4. Usamos nuestro traductor de errores profesional
      throw ApiException.fromDioError(e);
    } catch (e) {
      // Error genérico si algo falla en la lógica local
      throw ApiException("Error inesperado al guardar el movimiento");
    }
  }
}
