import 'package:segadi/core/network/fracttal_api_client.dart';
import 'package:segadi/features/maintenance/data/datasources/maintenance_report_remote_datasource.dart';

import '../models/maintenance_report_model.dart';

class MaintenanceReportRemoteDataSourceImpl
    implements MaintenanceReportsRemoteDatasource {
  MaintenanceReportRemoteDataSourceImpl(
    this._client,
  );

  final FracttalApiClient _client;

  Future<List<MaintenanceReportModel>> getReports({
    required String codeCreator,
  }) async {
    final response = await _client.request(
      '/work_requests',
      queryParameters: {
        'code_creator': codeCreator,
      },
    );

    return _parseReports(response.data);
  }

  Future<MaintenanceReportModel> getReportDetail({
    required int code,
  }) async {
    final response = await _client.request(
      '/work_requests/$code',
    );

    final reports = _parseReports(response.data);

    if (reports.isEmpty) {
      throw Exception('No se encontró la solicitud $code');
    }

    return reports.first;
  }

  List<MaintenanceReportModel> _parseReports(dynamic response) {
    if (response is! Map) {
      throw Exception('Respuesta inválida de Fracttal');
    }

    if (response['success'] == false) {
      throw Exception(
        response['message'] ?? 'Error consultando solicitudes',
      );
    }

    final data = response['data'];

    if (data == null) return [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => MaintenanceReportModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    if (data is Map) {
      return [
        MaintenanceReportModel.fromJson(
          Map<String, dynamic>.from(data),
        ),
      ];
    }

    throw Exception('Formato de respuesta no reconocido');
  }
}
