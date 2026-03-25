import 'package:dio/dio.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';

class RegistroMovimientoRemoteDataSource {
  final Dio _dio;
  RegistroMovimientoRemoteDataSource(this._dio);

  Future<Map<String, dynamic>> enviar(MovimientoRegistro movimiento) async {
    final response = await _dio.post(
      'index.php',
      queryParameters: {'r': 'esegadi/movimientosgruapost'},
      data: movimiento.toJson(),
    );
    return response.data;
  }
}
