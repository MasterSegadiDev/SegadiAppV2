import 'dart:convert';
import 'package:segadi/utils/global_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class SupportStatusApi {
  final String baseUrl = GlobalVariables.baseUrl;
  final Map<String, String> headers = GlobalVariables.headers;
  Future<http.Response> sendSupportStatus({
    required int serviceId,
    required int statusId,
    required String type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final data = {
      "service_id": serviceId,
      "status_id": statusId,
      "type": type,
      "token": token,
    };

    final body = json.encode(data);
    final url = Uri.parse('${baseUrl}index.php?r=esegadi/estatus-soportepost');

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response;
  }
}
