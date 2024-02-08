import 'dart:convert';

import 'package:segadi/model/services/services.dart';

import 'package:segadi/view_model/globals.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class ServicesModel {
  List<Services> services = [];

  getServices() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/getactivas',
          'id': id.toString(),
          'token': token,
        }))
        .timeout(const Duration(seconds: 90));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in data) {
        services.add(Services.fromJson(index));
      }

      return services;
    } else {
      return services;
    }
  }
}
