import 'package:dio/dio.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/features/check_list/domain/entities/checklist_item_model.dart';
import 'package:segadi/features/service_detail/core/errors/dio_exceptions.dart';
import 'package:segadi/features/services_assigned/core/errors/exceptions.dart';

class ChecklistRemoteDataSource {
  final Dio _dio = DioClient.instance;

  ChecklistRemoteDataSource();

  /// GET catálogo de puntos de revisión
  Future<List<ChecklistItemModel>> getChecklistCatalog(String token) async {
    try {
      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/get-puntosrevision',
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => ChecklistItemModel.fromJson(json)).toList();
      } else {
        throw ServerException(
            message:
                'Ha ocurrido un error al consultar el listado del checklist: ${response.statusCode}',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      // Aquí es donde el usuario deja de ver "Exception" y ve un mensaje real
      throw DioExceptions.fromDioError(e).message;
    }
  }

  /// POST guardar checklist
  Future<bool> saveChecklist({
    required int serviceId,
    required List<int> checkedIds,
    required String token,
  }) async {
    try {
      final data = {
        "service": {
          "service_id": serviceId,
          "list": checkedIds,
        },
        "token": token,
      };

      final response = await _dio.post(
        'index.php?r=esegadi/checklistpost',
        data: data,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e).message;
    }
  }
}
