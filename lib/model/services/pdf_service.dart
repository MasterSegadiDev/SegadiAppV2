

import 'dart:convert';

import 'package:segadi/view_model/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class PdfService {
  String? url;

  Future getPdf(serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getcfdi',
      'token': token,
      'id': userId.toString(),
      'service_id': serviceId.toString(),
    }));

     var data = jsonDecode(response.body.toString());
    if (response.statusCode == 200) {
      return data;
    }
  }
}
