import 'package:segadi/features/ubications/data/models/movimiento_model.dart';
import 'package:segadi/features/ubications/data/models/ubicaciones_mapa_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UbicacionesRemoteDataSource {
  Future<InventarioMapaModel> fetchMapaUbicaciones(String siteId);
}

// Implementación con Dio
class UbicacionesRemoteDataSourceImpl implements UbicacionesRemoteDataSource {
  final dynamic _dio; // Usa tu instancia de Dio configurada

  UbicacionesRemoteDataSourceImpl(this._dio);

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
}
