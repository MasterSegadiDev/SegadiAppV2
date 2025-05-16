import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segadi/models/containers/container_movement_list.dart';
import 'package:segadi/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovimientoService {
  final String baseUrl = GlobalVariables.baseUrl;
  Future<List<ContainerMovement>> fetchMovimientos() async {
    late int id;
    late String? token;

    final prefs = await SharedPreferences.getInstance();
    id = prefs.getInt('id') ?? 0;
    token = prefs.getString('token');
    var route = 'index.php';

    print(('ID USUARIO: ${id}'));
    print('TOKEN USUARIO: ${token}');

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
      return data.map((item) => ContainerMovement.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los movimientos');
    }

    // final List<Map<String, dynamic>> data = [
    //   {
    //     "id": 1,
    //     "folio_movimiento": "FM-20250401-001",
    //     "tipo_movimiento": "Traslado Interno",
    //     "remision": "REM-9812",
    //     "contenedor_a_mover": "A",
    //     "numero_contenedor_a": "CNT-00123",
    //     "numero_contenedor_b": "CNT-00456"
    //   },
    //   {
    //     "id": 2,
    //     "folio_movimiento": "FM-20250401-002",
    //     "tipo_movimiento": "Reubicación",
    //     "remision": "REM-9813",
    //     "contenedor_a_mover": "B",
    //     "numero_contenedor_a": "CNT-00124",
    //     "numero_contenedor_b": "CNT-00457"
    //   },
    //   {
    //     "id": 3,
    //     "folio_movimiento": "FM-20250401-003",
    //     "tipo_movimiento": "Entrada",
    //     "remision": "REM-9814",
    //     "contenedor_a_mover": "C",
    //     "numero_contenedor_a": "CNT-00125",
    //     "numero_contenedor_b": "CNT-00458"
    //   }
    // ];

    // Simula una llamada asíncrona
    // await Future.delayed(const Duration(milliseconds: 500));
    // return data.map((item) => MovimientoModel.fromJson(item)).toList();
  }
}
