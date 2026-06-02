import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:segadi/core/network/api_exceptions.dart';

class TripClosureRemoteDataSource {
  final Dio _dio;

  TripClosureRemoteDataSource(this._dio);

  Future<void> send(int serviceId, Uint8List pdfBytes) async {
    try {
      // 1. Obtenemos el token (mantenemos tu lógica de ViewModel por ahora)
      //final token = await LoginViewModel.getSavedToken();
      final token = '1234567890';

      // 2. Construimos el cuerpo del mensaje
      // Dio convertirá esto a JSON automáticamente
      final Map<String, dynamic> data = {
        "service_id": serviceId.toString(),
        "token": token,
        "receiver_name": '',
        "receiver_date": '',
        "file_type": "pdf",
        "document_name": "EIR Operador",
        "document_type": "EIR",
        "document_description": "EIR",
        "document": base64Encode(pdfBytes), // El PDF en base64
      };

      // 3. Realizamos la petición con Dio
      final response = await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/evidenciaspost'},
        data: data,
      );

      // 4. Validación lógica (opcional, dependiendo de tu backend)
      if (response.data is Map && response.data['success'] == false) {
        throw ApiException(response.data['message'] ??
            'Ha ocurrido un error al enviar el archivo PDF para el cierre del viaje');
      }

      print('Cierre de viaje enviado con éxito: ${response.statusCode}');
    } on DioException catch (e) {
      // Usamos nuestro unificador profesional de errores
      throw ApiException.fromDioError(e);
    } catch (e) {
      // Error genérico si algo falla en el base64Encode o lógica interna
      throw ApiException("Error inesperado al procesar el cierre de viaje");
    }
  }
}
