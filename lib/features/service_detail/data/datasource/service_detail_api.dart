import 'dart:async';
import 'dart:convert';

import 'package:segadi/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DetailServiceApi {
  final String baseUrl;

  DetailServiceApi(this.baseUrl);

  Future<Map<String, dynamic>> getDetailRaw(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final uri = Uri.parse('${GlobalVariables.baseUrl}/index.php').replace(
        queryParameters: {
          'r': 'esegadi/getdetalle',
          'id_remision': id.toString(),
          'token': prefs.getString('token') ?? '',
          'id': (prefs.getInt('id') ?? 0).toString(),
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Error HTTP ${response.statusCode}');
      }

      final decoded = json.decode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor');
      }

      return decoded;
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    }
  }
}
