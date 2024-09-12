import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

List<TableExpenses> tableExpensesFromJson(String str) =>
    List<TableExpenses>.from(
        json.decode(str).map((x) => TableExpenses.fromJson(x)));

String tableExpensesToJson(List<TableExpenses> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TableExpenses {
  int? id;
  String? paymentConcept;
  String? totalUsed;

  TableExpenses({
    this.id,
    this.paymentConcept,
    this.totalUsed,
  });

  factory TableExpenses.fromJson(Map<String, dynamic> json) => TableExpenses(
        id: json["id"],
        paymentConcept: json["payment_concept"],
        totalUsed: json["total_used"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "payment_concept": paymentConcept,
        "total_used": totalUsed,
      };

  final storage = const FlutterSecureStorage();

  Future<List<TableExpenses>> getTravelExpenses(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    String? token;
    token = await storage.read(key: 'token');
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/getcomprobacionestabla',
          'id': userId.toString(),
          'id_remision': id.toString(),
          'token': token,
        }))
        .timeout(const Duration(seconds: 90));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());

      data.removeWhere((str) {
        return str["total_used"] == "0.00";
      });

      List jsonResponse = data as List;

      var datas = jsonResponse.map((e) => TableExpenses.fromJson(e)).toList();

      return datas;
    } else {
      throw Exception(
          'Ha ocurrido un error al consultar el listado de los viaticos registrados');
    }
  }
}
