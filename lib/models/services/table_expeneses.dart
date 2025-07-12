import 'dart:convert';

import 'package:segadi/utils/global_variables.dart';
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
  String? paymentDocument;
  String? paymentExtention;
  int? image;

  TableExpenses({
    this.id,
    this.paymentConcept,
    this.totalUsed,
    this.paymentDocument,
    this.paymentExtention,
    this.image,
  });

  factory TableExpenses.fromJson(Map<String, dynamic> json) => TableExpenses(
      id: json["id"],
      paymentConcept: json["payment_concept"],
      totalUsed: json["total_used"],
      paymentDocument: json["payment_document"],
      paymentExtention: json["payment_extension"],
      image: json["image"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "payment_concept": paymentConcept,
        "total_used": totalUsed,
        "payment_document": paymentConcept,
        "payment_extension": paymentConcept,
        "image": image
      };

  final String baseUrl = GlobalVariables.baseUrl;
  final Map<String, String> headers = GlobalVariables.headers;

  Future<List<TableExpenses>> getTravelExpenses(int remition_id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    String? token;
    token = prefs.getString('token');

    var response = await http
        .get(Uri.parse('${GlobalVariables.baseUrl}index.php')
            .replace(queryParameters: {
          'r': 'esegadi/getcomprobacionestabla',
          'id': userId.toString(),
          'id_remision': GlobalVariables.serviceDetailId.toString(),
          'token': token,
        }))
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      return data.map((json) => TableExpenses.fromJson(json)).toList();
    } else {
      throw Exception('Ha ocurrido un error al consultar los viaticos');
    }
  }
}
