import 'package:dio/dio.dart';
import 'package:segadi/features/ubications/data/models/movimiento_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MovimientoRemoteDataSource {
  Future<List<MovimientoGruaModel>> fetchMovimientos(String siteId);
}

class MovimientoRemoteDataSourceImpl implements MovimientoRemoteDataSource {
  final Dio _dio;

  MovimientoRemoteDataSourceImpl(this._dio);

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
}
