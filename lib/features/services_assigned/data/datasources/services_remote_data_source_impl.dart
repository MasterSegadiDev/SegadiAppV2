import 'package:dio/dio.dart';
import 'package:segadi/core/errors/exceptions.dart';

import 'package:segadi/features/services_assigned/data/datasources/services_remote_data_source.dart';
import 'package:segadi/features/services_assigned/domain/entities/services_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/features/services_assigned/data/models/service_model.dart';

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final Dio dio;

  ServicesRemoteDataSourceImpl(this.dio);

  @override
  Future<ServicesResult> getAssignedServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int id = prefs.getInt('id') ?? 0;
      final String token = prefs.getString('token') ?? '';

      final response = await dio.get('index.php', queryParameters: {
        'r': 'esegadi/getactivas',
        'id': id.toString(),
        'token': token,
      });

      final data = response.data;

      if (data['success'] == "true") {
        final List dataList = data['data'] ?? [];

        return ServicesResult(
          items: dataList
              .map((json) => ServiceModel.fromJson(json).toEntity())
              .toList(),
          message: data['message'] ?? 'Consulta exitosa',
        );
      } else {
        return ServicesResult(
          items: [],
          message: data['message'] ?? 'Error en la consulta',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      }

      throw ServerException('Error del servidor: ${e.message}');
    }
  }
}
