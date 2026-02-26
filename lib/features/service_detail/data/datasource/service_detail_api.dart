import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/core/network/api_exceptions.dart';

class DetailServiceApi {
  final Dio _dio;

  // Ahora recibe la instancia de Dio inyectada
  DetailServiceApi(this._dio);

  Future<Map<String, dynamic>> getDetailRaw(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Con Dio, los parámetros van en queryParameters
      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getdetalle',
          'id_remision': id.toString(),
          'token': prefs.getString('token') ?? '',
          'id': (prefs.getInt('id') ?? 0).toString(),
        },
      );

      // Dio ya entrega los datos decodificados en response.data
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Usamos tu nuevo unificador de errores
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
          'Ha ocurrido un error inesperado al obtener los detalles del servicio');
    }
  }
}
