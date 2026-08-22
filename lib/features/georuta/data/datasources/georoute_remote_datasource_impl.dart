import 'package:dio/dio.dart';

import '../models/geofence_model.dart';
import 'georoute_remote_datasource.dart';

class GeorouteRemoteDatasourceImpl implements GeorouteRemoteDatasource {
  final Dio _dio;

  GeorouteRemoteDatasourceImpl({
    required Dio dio,
  }) : _dio = dio;

  @override
  Future<GeofenceModel> getGeofences(
    String serviceRequestId,
  ) async {
    final response = await _dio.get(
      '/api/mobile/appUser/referral/$serviceRequestId/geofences',
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida al consultar las geocercas.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ?? 'No se pudieron obtener las geocercas.',
      );
    }

    final result = data['Result'];

    if (result is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta de geocercas no contiene Result válido.',
      );
    }

    return GeofenceModel.fromJson(
      result,
    );
  }
}
