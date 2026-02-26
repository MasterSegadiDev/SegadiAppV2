import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/core/network/api_result.dart';
import 'package:segadi/viewmodels/login/user_login.dart';

class DetailServiceApi {
  final Dio _dio;

  // Recibe la instancia de Dio desde tu DioClient
  DetailServiceApi(this._dio);

  Future<Map<String, dynamic>> fetchDetailRaw(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getdetalle',
          'id_remision': id.toString(),
          'token': prefs.getString('token') ?? '',
          'id': (prefs.getInt('id') ?? 0).toString(),
        },
      );

      return response.data;
    } on DioException catch (e) {
      print('DioException en fetchDetailRaw: ${e.message}, tipo: ${e.type}');
      throw _mapDioErrorToString(e);
    } catch (e) {
      print('error inesperado en el catch: $e');
      throw 'Error inesperado al obtener detalle';
    }
  }

  Future<ApiResult> changeStatus({
    required int serviceId,
    required int statusId,
  }) async {
    try {
      final token = await LoginViewModel.getSavedToken();

      final response = await _dio.post(
        'index.php?r=esegadi/estatuspost',
        data: {
          'service_id': serviceId.toString(),
          'status_id': statusId.toString(),
          'token': token,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final json = response.data;
      if (json['status'] != null) {
        return ApiResult.success(json['status']);
      }
      return ApiResult.failure('Respuesta inválida del servidor');
    } on DioException catch (e) {
      return ApiResult.failure(_mapDioErrorToString(e));
    } catch (e) {
      return ApiResult.failure('Error inesperado al cambiar estatus');
    }
  }

  // MÉTODO MAESTRO PARA TRADUCIR ERRORES TÉCNICOS A MENSAJES HUMANOS
  String _mapDioErrorToString(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'El servidor tarda mucho en responder. Revisa tu señal.';
    }

    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException ||
        e.message?.contains('SocketException') == true ||
        e.message?.contains('Network is unreachable') == true) {
      return 'No tienes internet. Verifica tus datos o Wi-Fi.';
    }

    if (e.type == DioExceptionType.badResponse) {
      final data = e.response?.data;
      if (data is Map) {
        return data['error_message'] ??
            data['message'] ??
            'Error del servidor (${e.response?.statusCode})';
      }
    }

    return 'Error de red. Intenta más tarde.';
  }

  Future<ApiResult> cloaseService({
    required int id,
  }) async {
    try {
      final token = await LoginViewModel.getSavedToken();

      final response = await _dio.post(
        'index.php?r=esegadi/cierreevidenciaspost',
        data: {
          'service_id': id.toString(),
          'token': token,
          'close': 1,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final json = response.data;
      print('json data en closeService: $json');
      if (json != null) {
        return ApiResult.success(json);
      }
      return ApiResult.failure('Respuesta inválida del servidor');
    } on DioException catch (e) {
      return ApiResult.failure(_mapDioErrorToString(e));
    } catch (e) {
      return ApiResult.failure('Error inesperado al cambiar estatus');
    }
  }
}
