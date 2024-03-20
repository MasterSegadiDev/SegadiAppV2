import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiProvider {
  final String _baseURL = "http://198.251.68.42/DesarrolloSEGADI/web/";
  var route = 'index.php';

  get(String token, int id) async {
    try {
      final response = await http
          .get(Uri.parse(_baseURL + route).replace(queryParameters: {
            'r': 'esegadi/getactivas',
            'id': id.toString(),
            'token': token,
          }))
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      }
    } catch (e) {
      //bad practice to print error use logger
      // print(e);
      rethrow;
    }
  }

  post(String url, Map<String, dynamic> data) async {
    try {
      String jsondata = json.encode(data);
      final response =
          await http.post(Uri.parse(_baseURL + url), body: jsondata, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      //bad practice to print error use logger
      // print(e);
      rethrow;
    }
  }

  put(String url, Map<String, dynamic> data) async {
    try {
      String jsondata = json.encode(data);
      final response =
          await http.put(Uri.parse(_baseURL + url), body: jsondata, headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      //bad practice to print error use logger
      // print(e);
      rethrow;
    }
  }

  delete(String url) async {
    try {
      final response = await http.delete(Uri.parse(_baseURL + url));

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      //bad practice to print error use logger
      // print(e);
      rethrow;
    }
  }
}
