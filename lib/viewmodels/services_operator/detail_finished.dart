import 'dart:convert';
import 'dart:developer';

import 'package:segadi/models/services/detail_finished.dart';
import 'package:segadi/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class Detail {
  final String baseUrl = GlobalVariables.baseUrl;
  final Map<String, String> headers = GlobalVariables.headers;

  Future<DetailFinished>? getService(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var userRollPrefs = prefs.getString('user_roll') ?? '';
    var route = 'index.php';

    var response =
        await http.get(Uri.parse(baseUrl + route).replace(queryParameters: {
      'r': 'esegadi/getterminadasdetalle',
      'id': userId.toString(),
      'service_id': id.toString(),
      'token': token,
    }));

    if (response.statusCode == 200) {
      inspect(response.body);
      var result = DetailFinished.fromJson(json.decode(response.body));

      if (userRollPrefs == 'Si') {
        result.userRoll = true;
      }
      inspect(result);

      return result;
    } else {
      throw Exception('Failed to load detail');
    }
  }
}
