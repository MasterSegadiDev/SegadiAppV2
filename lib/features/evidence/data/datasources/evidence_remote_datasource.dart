import 'package:dio/dio.dart';
import 'package:segadi/core/network/api_exceptions.dart';

class EvidenceRemoteDataSource {
  final Dio _dio;

  EvidenceRemoteDataSource(this._dio);

  Future<void> postEvidence(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/evidenciaspost'},
        data: body,
      );

      if (response.data is Map && response.data['success'] == false) {
        throw ApiException(response.data['message'] ??
            'Ha ocurrido un error al enviar evidencias');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException("Error inesperado al enviar evidencias");
    }
  }
}
