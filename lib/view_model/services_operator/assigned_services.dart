import 'package:segadi/model/services/services.dart';
import 'package:segadi/repo/api_status.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class ServicesModel {
  static Future<Object> getServices() async {
    try {
      int id = 0;
      String token = "";

      final prefs = await SharedPreferences.getInstance();
      id = prefs.getInt('id') ?? 0;
      token = prefs.getString('token') ?? '';

      var response = await http.get(
          Uri.parse("http://198.251.68.42/DesarrolloSEGADI/web/index.php")
              .replace(queryParameters: {
        'r': 'esegadi/getactivas',
        'id': id,
        'token': token,
      }));

      if (response.statusCode == 200) {
        return Success(response: servicesFromJson(response.body));
      }
      return Failure(code: 100, errorResponse: 'Invalid Response');
    } catch (e) {
      return Failure(code: 103, errorResponse: 'Unknown Error');
    }
  }
}
