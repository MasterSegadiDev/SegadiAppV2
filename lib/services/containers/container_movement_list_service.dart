import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segadi/models/containers/container_movement_list.dart';
import 'package:segadi/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovimientoService {
  final String baseUrl = GlobalVariables.baseUrl;
  Future<List<ContainerMovement>> fetchMovimientos({
    required bool forceReload,
    required String siteId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('id') ?? 0;
      final String? token = prefs.getString('token');

      print('🔹 DEBUG fetchMovimientos');
      print('🔸 userId: $userId');
      print('🔸 token: $token');
      print('🔸 siteId: $siteId');

      if (userId == 0 || token == null || siteId.isEmpty) {
        throw Exception('Usuario, token o site_id inválido');
      }
      print('SITE ID NUMERO: ${siteId}');

      final route = 'index.php';
      final uri = Uri.parse(baseUrl + route).replace(queryParameters: {
        'r': 'esegadi/getmovimientosgrua',
        'id': userId.toString(),
        'token': token,
        'site_id': siteId,
      });
      print('URL DE MOVIMIENTOS: ${uri}');

      final response = await http.get(uri);

      print('ESTATUS LISTADO DE MOVIMIENTOS: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Error HTTP al cargar los movimientos');
      }

      final List<dynamic> data = json.decode(response.body);
      print('📦 CANTIDAD DE MOVIMIENTOS RECIBIDOS: ${data.length}');

      return data.map((item) => ContainerMovement.fromJson(item)).toList();
    } catch (e, stackTrace) {
      print('ERROR fetchMovimientos: $e');
      print(stackTrace);
      throw Exception(
          'No se pudieron cargar los movimientos. Intente de nuevo.');
    }
  }
}
