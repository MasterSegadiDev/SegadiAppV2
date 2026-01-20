import 'dart:convert';
import 'dart:typed_data';

import 'package:segadi/utils/global_variables.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:http/http.dart' as http;

class TripClosureRemoteDataSource {
  Future<void> send(int serviceId, Uint8List pdfBytes) async {
    final token = await LoginViewModel.getSavedToken();
    print('entrando a la funcion send pdf');

    // final body = {
    //   "service_id": serviceId.toString(),
    //   "token": token,
    //   "file_type": "pdf",
    //   "document_name": "EIR",
    //   "document_type": "EIR",
    //   "document_description": "EIR",
    //   "document": base64Encode(pdfBytes),
    // };

    final Map<String, dynamic> body = {
      "service_id": serviceId.toString(),
      "token": token,
      "receiver_name": '',
      "receiver_date": '',
      "file_type": "pdf",
      "document_name": "EIR",
      "document_type": "EIR",
      "document_description": "EIR",
      "document": base64Encode(pdfBytes),
    };

    print('body a enviar ${body}');

    final response = await http.post(
      Uri.parse('${GlobalVariables.baseUrl}index.php?r=esegadi/evidenciaspost'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print('RESPUESTA: ${response.statusCode}');
  }
}
