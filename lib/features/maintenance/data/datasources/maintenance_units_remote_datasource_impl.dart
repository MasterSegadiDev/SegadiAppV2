import 'package:dio/dio.dart';
import 'package:segadi/core/errors/dio_exception_handler.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/features/maintenance/data/datasources/maintenance_units_remote_datasource.dart';
import 'package:segadi/features/maintenance/data/models/maintenance_unit_assigned_model.dart';
import 'package:segadi/features/maintenance/data/models/maintenance_units_list_model.dart';

class MaintenanceUnitsRemoteDataSourceImpl
    implements MaintenanceUnitsRemoteDatasource {
  final Dio _dio;
  MaintenanceUnitsRemoteDataSourceImpl({Dio? dio})
      : _dio = dio ?? DioClient.instance;

  @override
  Future<List<MaintenanceUnitModel>> getActiveUnits() async {
    try {
      final response = await _dio.get(
        '/units/active',
      );

      final List<dynamic> result = response.data['Result'] ?? [];

      return result
          .map(
            (json) => MaintenanceUnitModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  Future<MaintenanceUnitDetailModel?> getAssignedUnit() async {
    final response = await _dio.get(
      '/units/assigned',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'No fue posible consultar la unidad asignada.',
      );
    }

    final result = data['Result'];

    if (result == null) {
      return null;
    }

    return MaintenanceUnitDetailModel.fromJson(
      result as Map<String, dynamic>,
    );
  }

  Future<void> validarUnidad() async {
    return null;
  }
}
