import 'dart:convert';

import 'package:segadi/utils/global_variables.dart';
import 'package:http/http.dart' as http;

class EvidenceRemoteDataSource {
  Future<void> postEvidence(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse("${GlobalVariables.baseUrl}index.php?r=esegadi/evidenciaspost"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print('respuesta del envio de evidencias ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
