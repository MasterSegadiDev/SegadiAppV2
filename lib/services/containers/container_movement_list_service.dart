import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:segadi/models/containers/container_movement_list.dart';

class MovimientoService {
  final Dio _dio;

  // Recibimos Dio por constructor (Inyección de Dependencias)
  MovimientoService(this._dio);

  Future<List<ContainerMovement>> fetchMovimientos({
    required bool forceReload,
    required String siteId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('id') ?? 0;
      final String? token = prefs.getString('token');

      // Validación previa profesional
      if (userId == 0 || token == null || siteId.isEmpty) {
        throw ApiException('Sesión inválida o sitio no especificado.');
      }

      // Realizamos la petición con Dio
      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getmovimientosgrua',
          'id': userId.toString(),
          'token': token,
          'site_id': siteId,
        },
      );

      // Dio ya entrega los datos decodificados (List o Map)
      if (response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((item) => ContainerMovement.fromJson(item)).toList();
      }

      return []; // Devolvemos lista vacía si el formato no es el esperado
    } on DioException catch (e) {
      // Usamos tu unificador profesional de errores de red
      throw ApiException.fromDioError(e);
    } catch (e) {
      // Capturamos cualquier error de mapeo o lógica interna
      throw ApiException('Error al procesar el listado de movimientos.');
    }
  }
}
