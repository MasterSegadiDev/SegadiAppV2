import 'package:dio/dio.dart';
import 'package:segadi/core/network/api_exceptions.dart';

class EvidenceRemoteDataSource {
  final Dio _dio;

  EvidenceRemoteDataSource(this._dio);

  // Future<void> postEvidence(Map<String, dynamic> body) async {
  //   try {
  //     final response = await _dio.post(
  //       'index.php',
  //       queryParameters: {'r': 'esegadi/evidenciaspost'},
  //       data: body,
  //     );

  //     if (response.data is Map && response.data['success'] == false) {
  //       throw ApiException(response.data['message'] ??
  //           'Ha ocurrido un error al enviar evidencias');
  //     }
  //   } on DioException catch (e) {
  //     throw ApiException.fromDioError(e);
  //   } catch (e) {
  //     throw ApiException("Error inesperado al enviar evidencias");
  //   }
  // }

  Future<void> postEvidence(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/evidenciaspost'},
        data: body,
      );

      // Validamos el campo 'success' o la existencia de errores en el mapa
      if (response.data is Map) {
        if (response.data['success'] == false ||
            response.data.containsKey('error_message')) {
          throw ApiException(response.data['error_message'] ??
              response.data['message'] ??
              'Error al procesar la evidencia');
        }
      }
    } on DioException catch (e) {
      // Esto usará la lógica de fromDioError que extrae el JSON del servidor
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException("Error inesperado al enviar evidencias");
    }
  }
}
