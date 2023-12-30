import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:segadi/model/services/travel_expenses.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelExpensesService {
  Future<http.Response> insertImport(
      int serviceId, int moneyCheckId, dynamic importTotal, comentary) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    Map data = {
      "service_id": serviceId,
      "token": token,
      "money_check_id": moneyCheckId,
      "total_used": importTotal,
      "comments": comentary,
    };

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/comprobacionespost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(response.statusCode);
    return response;
  }

  getData(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';

    var data;

    final result = await http.get(
        Uri.parse("http://198.251.68.42/DesarrolloSEGADI/web/index.php")
            .replace(queryParameters: {
      'r': 'esegadi/getcomprobaciones',
      'id': userId.toString(),
      'id_remision': id.toString(),
      'token': token,
    }));
    var jsonData = json.decode(result.body.toString());

    if (jsonData["error_message"] != null) {
      data = [];
    } else {
      data = jsonData;
    }

    return data;
  }

  Future<List<TravelExpenses>> getTravelExpenses(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/getcomprobacionestabla',
          'id': userId.toString(),
          'id_remision': id.toString(),
          'token': token,
        }))
        .timeout(const Duration(seconds: 90));

    var data = jsonDecode(response.body.toString());

    data.removeWhere((str) {
      return str["total_used"] == "0.00";
    });
    // inspect(data);
    List jsonResponse = data as List;

    var datas = jsonResponse.map((e) => TravelExpenses.fromJson(e)).toList();

    return datas;
  }
}
