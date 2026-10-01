import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/features/local_service/data/datasources/stretch_remote_data_source.dart';
import 'package:segadi/features/local_service/data/models/stretch_model.dart';
import 'package:segadi/features/local_service/domain/entities/stretch.dart';

import '../../domain/enums/tramo_status.dart';

class TramoRemoteDataSourceImpl implements TramoRemoteDataSource {
  TramoRemoteDataSourceImpl({
    Dio? dio,
  }) : _dio = dio ?? DioClient.instance;

  final Dio _dio;
  @override
  Future<Tramo?> getActiveTramo() async {
    final response = await _dio.get(
      '/tramo/active',
    );

    debugPrint(
      'GET TRAMO RESPONSE: ${response.data}',
    );

    final data = response.data as Map<String, dynamic>;

    final success = data['success'] as bool? ?? false;

    if (!success) {
      throw Exception(
        data['message'] ?? 'No fue posible obtener el tramo.',
      );
    }

    final result = data['Result'];

    if (result == null) {
      return null;
    }

    return TramoModel.fromJson(
      result as Map<String, dynamic>,
    );
  }

  @override
  Future<void> updateStatus({
    required String referralId,
    required int tramoIndex,
    required TramoStatus status,
  }) async {
    final response = await _dio.post(
      '/api/mobile/tramo/'
      '$referralId/'
      '$tramoIndex/'
      'status',
      data: {
        'status': status.apiValue,
      },
    );

    final data = response.data as Map<String, dynamic>;

    final success = data['success'] as bool? ?? false;

    if (!success) {
      throw Exception(
        data['message'] ?? 'No fue posible actualizar el estado.',
      );
    }
  }
}
