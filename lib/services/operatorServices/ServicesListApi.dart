import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/models/services/services.dart';
import 'package:segadi/utils/global_variables.dart';

class ServicesApi {
  static Future<List<Services>> fetchAssignedServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int id = prefs.getInt('id') ?? 0;
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Token inválido o no disponible.');
      }

      final uri = Uri.parse('${GlobalVariables.baseUrl}index.php').replace(
        queryParameters: {
          'r': 'esegadi/getactivas',
          'id': id.toString(),
          'token': token,
        },
      );

      final response = await http.get(uri);

      print('[ServicesApi] STATUS: ${response.statusCode}');
      print('[ServicesApi] BODY: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Services.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener servicios: ${response.statusCode}');
      }
    } catch (e) {
      print('[ServicesApi] Error: $e');
      return [];
    }
  }
}
