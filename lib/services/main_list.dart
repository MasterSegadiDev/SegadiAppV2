import 'dart:convert';
import 'package:http/http.dart' as http;

class MainServices {
  Future<void> main() async {
    final int id = 1;
    final String url = 'https://pokeapi.co/api/v2/pokemon/$id';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      print(data);
    } catch (e) {
      print('Ha ocurrido un error: $e');
    }
  }
}
