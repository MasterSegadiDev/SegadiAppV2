import 'dart:convert';

import 'package:segadi/models/services/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/services/globals.dart';
import 'package:http/http.dart' as http;

class ListServiceRemote {
  Future<List<Services>> getServices() async {
    var client = http.Client();
    int _id = 0;
    String _token = "";
    List<Services> services = [];

    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt('id') ?? 0;
    _token = prefs.getString('token') ?? '';
    var route = 'index.php';

    /*var url = Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getactivas',
      'id': _id.toString(),
      'token': _token,
    });*/

    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getactivas',
      'id': _id.toString(),
      'token': _token,
    }));
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
