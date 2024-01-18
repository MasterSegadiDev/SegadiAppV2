import 'dart:convert';

import 'package:segadi/model/services/detail_finished.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class Detail {
  Future<DetailFinished>? getService(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getterminadasdetalle',
      'id': userId.toString(),
      'service_id': id.toString(),
      'token': token,
    }));

    if (response.statusCode == 200) {
      var result = DetailFinished.fromJson(json.decode(response.body));

      return result;
    } else {
      throw Exception('Failed to load detail');
    }
  }
}
