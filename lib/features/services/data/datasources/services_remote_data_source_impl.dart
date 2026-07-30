import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:segadi/core/errors/dio_exception_handler.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/core/security/session_manager.dart';
import 'package:segadi/features/services/data/datasources/services_remote_data_source.dart';
import 'package:segadi/features/services/data/models/service_detail_dto.dart';

import '../dto/assigned_service_dto.dart';

class ServicesRemoteDatasourceImpl implements ServicesRemoteDatasource {
  ServicesRemoteDatasourceImpl({
    Dio? dio,
  }) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  @override
  Future<List<AssignedServiceDto>> getAssignedServices() async {
    try {
      /// Obtiene el usuario almacenado en la sesión
      final user = await SessionManager.getUserId();

      if (user == null) {
        throw Exception('No existe una sesión activa.');
      }

      final response = await _dio.get(
        '/appUser/referrals/$user',
      );

      debugPrint(response.data.toString());
      debugPrint(response.toString());

      final List<dynamic> result = response.data['Result'] ?? [];

      return result
          .map(
            (json) => AssignedServiceDto.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  @override
  Future<ServiceDetailDto> getServiceDetail(
    String referralId,
  ) async {
    try {
      final response = await _dio.get(
        '/appUser/referral/$referralId',
      );

      return ServiceDetailDto.fromJson(
        response.data['Result'],
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
