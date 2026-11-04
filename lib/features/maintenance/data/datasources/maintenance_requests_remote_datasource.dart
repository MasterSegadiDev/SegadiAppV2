import 'package:dio/dio.dart';
import 'package:segadi/core/network/fracttal_api_client.dart';

import '../models/create_maintenance_request_model.dart';

class CreatedMaintenanceRequest {
  const CreatedMaintenanceRequest({
    required this.id,
    required this.identifier,
  });

  final int id;
  final String identifier;
}

class MaintenanceRequestDetail {
  const MaintenanceRequestDetail({
    required this.idCode,
    required this.statusId,
  });

  final int idCode;
  final int statusId;
}

class MaintenanceRequestsRemoteDataSource {
  const MaintenanceRequestsRemoteDataSource(
    this._client,
  );

  final FracttalApiClient _client;

  Future<CreatedMaintenanceRequest> createRequest(
    CreateMaintenanceRequestModel request,
  ) async {
    try {
      final response = await _client.request(
        'work_requests/',
        method: 'POST',
        data: request.toJson(),
      );

      final body = _parseSuccess(response.data);
      final data = body['data'];

      if (data is! List || data.isEmpty || data.first is! Map) {
        throw const FormatException(
          'Fracttal no devolvió la solicitud creada.',
        );
      }

      final id = _parseInt(
        (data.first as Map)['id'],
      );

      return CreatedMaintenanceRequest(
        id: id,
        identifier: request.identifier,
      );
    } on DioException catch (error) {
      throw Exception(
        'Error al crear solicitud en Fracttal '
        '(${error.response?.statusCode}): '
        '${error.response?.data}',
      );
    }
  }

  Future<MaintenanceRequestDetail> findCreatedRequest({
    required String identifier,
  }) async {
    // Consultas de lectura. No vuelve a crear nada.
    for (var attempt = 0; attempt < 5; attempt++) {
      final response = await _client.request(
        'work_requests/',
        method: 'GET',
        queryParameters: {
          'identifier': identifier,
          'limit': 100,
          'start': 0,
        },
      );

      final body = _parseSuccess(response.data);
      final data = body['data'];

      if (data is List) {
        for (final item in data) {
          if (item is! Map) continue;

          // Verificación adicional para no asociar
          // fotos a otra solicitud.
          if (item['identifier']?.toString() != identifier) {
            continue;
          }

          final idCode = _parseInt(item['id_code']);
          final statusId = _parseInt(item['id_status']);

          return MaintenanceRequestDetail(
            idCode: idCode,
            statusId: statusId,
          );
        }
      }

      if (attempt < 4) {
        await Future<void>.delayed(
          const Duration(seconds: 2),
        );
      }
    }

    throw StateError(
      'La solicitud fue creada, pero todavía no '
      'se pudo consultar su id_code e id_status. '
      'Referencia: $identifier. '
      'No vuelvas a crearla.',
    );
  }

  Map<String, dynamic> _parseSuccess(dynamic raw) {
    if (raw is! Map) {
      throw const FormatException(
        'Respuesta inválida de Fracttal.',
      );
    }

    final body = Map<String, dynamic>.from(raw);

    if (body['success'] != true) {
      throw Exception(
        'Fracttal: ${body['message']} '
        '${body['data']}',
      );
    }

    return body;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;

    final result = int.tryParse(value?.toString() ?? '');

    if (result == null) {
      throw FormatException(
        'Identificador numérico inválido: $value',
      );
    }

    return result;
  }
}
