import 'package:dio/dio.dart';
import 'package:segadi/core/network/api_exceptions.dart';
import 'package:segadi/models/contenedores/ubicacion.dart';

class UbicacionesService {
  final Dio _dio;

  // Inyectamos la instancia unificada de Dio
  UbicacionesService(this._dio);

  Future<List<Ubicacion>> fetchUbicaciones({
    required String siteId,
  }) async {
    try {
      // Usamos queryParameters para que la URL sea legible y segura
      // Nota: He dejado id=100 y token=1000 como estaban en tu código original,
      // pero recuerda que podrías obtenerlos dinámicamente si fuera necesario.
      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getubicaciones',
          'id': '100',
          'site_id': siteId,
          'token': '1000',
        },
      );

      // Dio ya nos da el Map decodificado en response.data
      final jsonData = response.data as Map<String, dynamic>;
      final raw = jsonData['ubicaciones'];

      if (raw is! List) return [];

      return raw
          .map((e) => Ubicacion.fromJson(e))
          .where(
              (u) => u.id.isNotEmpty) // Mantenemos tu filtro de IDs no vacíos
          .toList();
    } on DioException catch (e) {
      // Capturamos errores de red (timeout, sin internet, etc)
      throw ApiException.fromDioError(e);
    } catch (e) {
      // Capturamos errores de parseo o lógica interna
      throw ApiException('Error al procesar las ubicaciones del sitio.');
    }
  }
}
