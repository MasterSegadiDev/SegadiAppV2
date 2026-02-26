import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:segadi/models/contenedores/movimiento.dart';
import 'package:segadi/models/contenedores/movimientos_contenedor.dart';

class MovimientosService {
  final Dio _dio;

  // Inyectamos Dio para mantener la configuración global (URL, Logs, Timeouts)
  MovimientosService(this._dio);

  /// GUARDAR UN MOVIMIENTO (POST)
  Future<Map<String, dynamic>> saveMovimiento(Movimiento movimiento) async {
    try {
      final response = await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/movimientosgruapost'},
        data: movimiento.toJson(), // Dio serializa automáticamente
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('Error inesperado al guardar el movimiento');
    }
  }

  /// OBTENER LISTADO DE MOVIMIENTOS (GET)
  Future<List<ContainerMovement>> fetchMovimientos({
    required bool forceReload,
    required String siteId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('id') ?? 0;
      final String? token = prefs.getString('token');

      if (userId == 0 || token == null || siteId.isEmpty) {
        throw ApiException('Sesión inválida o sitio no especificado.');
      }

      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getmovimientosgrua',
          'id': userId.toString(),
          'token': token,
          'site_id': siteId,
        },
      );

      if (response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((item) => ContainerMovement.fromJson(item)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
          'No se pudieron cargar los movimientos. Intente de nuevo.');
    }
  }
}
