import 'package:segadi/features/ubications/data/models/movimiento_model.dart';
import 'package:segadi/features/ubications/data/models/ubicaciones_mapa_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UbicacionesRemoteDataSource {
  Future<List<MovimientoGruaModel>> fetchMovimientos(String siteId);
  Future<InventarioMapaModel> fetchMapaUbicaciones(String siteId);

  Future<bool> registrarMovimiento({
    required int movimientoId,
    required String ubicacionDestinoId,
    required String comentarios,
  });
}

// Implementación con Dio
class UbicacionesRemoteDataSourceImpl implements UbicacionesRemoteDataSource {
  final dynamic _dio; // Usa tu instancia de Dio configurada

  UbicacionesRemoteDataSourceImpl(this._dio);

  @override
  Future<List<MovimientoGruaModel>> fetchMovimientos(String siteId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int userId = prefs.getInt('id') ?? 0;
    try {
      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getmovimientosgrua',
          'id': userId.toString(),
          'token': token,
          'site_id': siteId,
        },
      );

      final List data = response.data;
      return data.map((json) => MovimientoGruaModel.fromJson(json)).toList();
    } catch (e) {
      rethrow; // El repositorio se encargará de atraparlo
    }
  }

  @override
  Future<InventarioMapaModel> fetchMapaUbicaciones(String siteId) async {
    final prefs = await SharedPreferences.getInstance();
    //final String? token = prefs.getString('token');
    final int userId = prefs.getInt('id') ?? 0;

    try {
      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getubicaciones', // Ajusta el endpoint según tu API
          'id': userId.toString(),
          'token': 1000,
          'site_id': siteId,
        },
      );

      // Como tu InventarioMapaModel.fromJson espera el Map con areas, espacios, etc.
      // Simplemente pasamos el response.data que ya trae esa estructura.
      return InventarioMapaModel.fromJson(response.data);
    } catch (e) {
      // Si la API devuelve un error o el JSON no tiene el formato correcto
      rethrow;
    }
  }

  @override
  Future<bool> registrarMovimiento({
    required int movimientoId,
    required String ubicacionDestinoId,
    required String comentarios,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int userId = prefs.getInt('id') ?? 0;

    final response = await _dio.post(
      'index.php',
      queryParameters: {
        'r': 'esegadi/registrarmovimiento', // Tu endpoint de registro
        'id': userId.toString(),
        'token': token,
      },
      data: {
        'movimiento_id': movimientoId,
        'ubicacion_id': ubicacionDestinoId,
        'comentarios': comentarios,
      },
    );
    return response.statusCode == 200;
  }
}
