import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:segadi/utils/global_variables.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistApi {
  final String baseUrl = GlobalVariables.baseUrl;

  /// GET catálogo
  Future<List<dynamic>> getChecklistCatalog() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse(
      '${GlobalVariables.baseUrl}'
      'index.php?r=esegadi/get-puntosrevision&token=$token',
    );

    print('ChecklistApi URI: $uri');

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    print('ChecklistApi status: ${response.statusCode}');
    print('ChecklistApi body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Error checklist');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  /// POST checklist marcado
  Future<bool> saveChecklist({
    required int serviceId,
    required List<int> checkedIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('${baseUrl}index.php?r=esegadi/checklistpost');

    final body = jsonEncode({
      "service": {
        "service_id": serviceId,
        "list": checkedIds,
      },
      "token": token,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint('CHECKLIST POST URL: $url');
    debugPrint('CHECKLIST POST BODY: $body');
    debugPrint('CHECKLIST POST STATUS: ${response.statusCode}');
    debugPrint('CHECKLIST POST RESPONSE: ${response.body}');

    return response.statusCode == 200;
  }
}
