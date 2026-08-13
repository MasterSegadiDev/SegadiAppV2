import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:segadi/core/errors/dio_exception_handler.dart';
import 'package:segadi/core/network/dio_client.dart';

import '../dto/support_status_dto.dart';
import 'support_status_remote_datasource.dart';

class SupportStatusRemoteDatasourceImpl
    implements SupportStatusRemoteDatasource {
  SupportStatusRemoteDatasourceImpl({
    Dio? dio,
  }) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  @override
  Future<List<SupportStatusDto>> getSupportStatuses() async {
    try {
      final response = await _dio.get(
        '/appUser/monitoring/support-status',
      );

      debugPrint(
        'SUPPORT STATUS RESPONSE: '
        '${response.data}',
      );

      final List<dynamic> result = response.data['Result'] ?? [];

      return result
          .map(
            (json) => SupportStatusDto.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      debugPrint(
        'SUPPORT STATUS ERROR: ${e.message}',
      );

      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<bool> sendSupportStatus({
    required String referralId,
    required String serviceRequestId,
    required String statusId,
  }) async {
    try {
      print('Estas entrando a enviar nuevo estatus de soporte !!!');
      final body = {
        'referral_id': referralId,
        'service_request_id': serviceRequestId,
        'status_id': statusId,
      };
      debugPrint(
        'SEND SUPPORT STATUS BODY: $body',
      );
      final response = await _dio.post(
        '/appUser/monitoring/support-status',
        data: body,
      );
      debugPrint(
        'SEND SUPPORT STATUS RESPONSE: ' '${response.data}',
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      debugPrint(
        'SEND SUPPORT STATUS ERROR: ${e.message}',
      );
      rethrow;
    }
  }
}
