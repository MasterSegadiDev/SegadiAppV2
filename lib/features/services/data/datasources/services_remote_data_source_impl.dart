import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:segadi/core/errors/dio_exception_handler.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/core/security/session_manager.dart';
import 'package:segadi/features/services/data/datasources/services_remote_data_source.dart';
import 'package:segadi/features/services/data/dto/service_general_dto.dart';
import 'package:segadi/features/services/data/dto/service_status_dto.dart';
import 'package:segadi/features/services/data/models/service_actions_model.dart';
import 'package:segadi/features/services/domain/entities/mandatory_status_result_entity.dart';
import 'package:segadi/features/services/domain/entities/update_mandatory_status_entity.dart';

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
  Future<ServiceGeneralDto> getServiceGeneral(
    String referralId,
  ) async {
    final response = await _dio.get(
      '/appUser/referral/$referralId/general',
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida al consultar los datos generales de la remisión.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'No se pudieron obtener los datos de la remisión.',
      );
    }

    final result = data['Result'];

    if (result is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta de datos generales no contiene Result válido.',
      );
    }

    return ServiceGeneralDto.fromJson(result);
  }

  @override
  Future<ServiceActionsModel> getServiceActions(
    String referralId,
  ) async {
    final response = await _dio.get(
      '/appUser/referral/$referralId/actions',
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida al consultar las acciones.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ?? 'No se pudieron obtener las acciones.',
      );
    }

    final result = data['Result'];

    if (result is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta de acciones no contiene Result válido.',
      );
    }

    final acciones = result['acciones'];

    if (acciones is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta no contiene acciones válidas.',
      );
    }

    return ServiceActionsModel.fromJson(
      acciones,
    );
  }

  @override
  Future<ServiceStatusDto> getServiceStatus(
    String referralId,
  ) async {
    final response = await _dio.get(
      '/appUser/referral/$referralId/status',
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida al consultar el estatus de la remisión.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ??
            'No se pudo obtener el estatus de la remisión.',
      );
    }

    final result = data['Result'];

    if (result is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta de estatus no contiene Result válido.',
      );
    }

    return ServiceStatusDto.fromJson(
      result,
    );
  }

  @override
  Future<MandatoryStatusResultEntity> updateMandatoryStatus(
    UpdateMandatoryStatusParams params,
  ) async {
    final response = await _dio.post(
      '/appUser/monitoring/mandatory-status',
      data: {
        'referral_id': params.referralId,
        'service_request_id': params.serviceRequestId,
        'status_id': params.statusId,
      },
    );

    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Respuesta inválida al actualizar el estatus.',
      );
    }

    if (data['success'] != true) {
      throw Exception(
        data['message']?.toString() ?? 'No se pudo actualizar el estatus.',
      );
    }

    final result = data['Result'];

    if (result is! Map<String, dynamic>) {
      throw Exception(
        'La respuesta no contiene un Result válido.',
      );
    }

    return MandatoryStatusResultEntity(
      //enableBtn: result['enableBtn'],
      nextMandatoryStatus: result['nextMandatoryStatus']?.toString() ?? '',
      nextMandatoryStatusId: result['nextMandatoryStatusId']?.toString() ?? '',
    );
  }
}
