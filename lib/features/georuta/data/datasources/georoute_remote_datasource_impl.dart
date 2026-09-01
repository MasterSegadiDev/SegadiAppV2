import 'package:dio/dio.dart';
import 'package:segadi/core/network/dio_client.dart';

import '../models/georoute_model.dart';
import 'georoute_remote_datasource.dart';

class GeorouteRemoteDatasourceImpl implements GeorouteRemoteDatasource {
  final Dio _dio;

  GeorouteRemoteDatasourceImpl({
    Dio? dio,
  }) : _dio = dio ?? DioClient.instance;

  @override
  Future<GeorouteModel> getGeoroute(
    String serviceRequestId,
  ) async {
    try {
      final response = await _dio.get(
        '/appUser/referral/$serviceRequestId/geofences',
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Respuesta inválida del servidor.',
        );
      }

      if (data['success'] != true) {
        throw Exception(
          data['message']?.toString() ?? 'No se pudo obtener la georuta.',
        );
      }

      final result = data['Result'];

      if (result is! Map<String, dynamic>) {
        throw Exception(
          'La respuesta no contiene un Result válido.',
        );
      }

      return GeorouteModel.fromJson(result);
    } on DioException catch (e) {
      throw Exception(
        e.message ?? 'Error de comunicación con el servidor.',
      );
    }
  }
}
