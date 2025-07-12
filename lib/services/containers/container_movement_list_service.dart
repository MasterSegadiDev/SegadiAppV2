import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segadi/models/containers/container_movement_list.dart';
import 'package:segadi/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovimientoService {
  final String baseUrl = GlobalVariables.baseUrl;
  Future<List<ContainerMovement>> fetchMovimientos(
      {required bool forceReload}) async {
    late int id;
    late String? token;

    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id') ?? 0;
    print(('ID USUARIO MOVIMIENTOS APP ${id}'));
    token = prefs.getString('token');
    var route = 'index.php';

    var response = await http.get(
      Uri.parse(baseUrl + route).replace(
        queryParameters: {
          'r': 'esegadi/getmovimientosgrua',
          'id': id.toString(),
          'token': token,
        },
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('📦 CANTIDAD DE MOVIMIENTOS RECIBIDOS: ${data.length}');
      return data.map((item) => ContainerMovement.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los movimientos');
    }
  }
}
