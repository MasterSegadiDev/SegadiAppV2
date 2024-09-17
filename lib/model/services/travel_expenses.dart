import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/view_model/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<TravelExpenses> travelExpensesFromJson(String str) =>
    List<TravelExpenses>.from(
        json.decode(str).map((x) => TravelExpenses.fromJson(x)));

String travelExpensesToJson(List<TravelExpenses> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TravelExpenses {
  int? id;
  //int? serviceId;
  int? paymentConceptId;
  String? paymentConcept;
  //String? totalUsed;
  String? paymentTotal;
  //String? comments;

  double? import;

  TravelExpenses({
    this.id,
    //this.serviceId,
    this.paymentConceptId,
    this.paymentConcept,
    //this.totalUsed,
    this.paymentTotal,
    //this.comments,
    this.import,
  });

  factory TravelExpenses.fromJson(Map<String, dynamic> json) => TravelExpenses(
        id: json["id"],
        //serviceId: json["service_id"],
        paymentConceptId: json["payment_concept_id"],
        paymentConcept: json["payment_concept"],
        //totalUsed: json["total_used"],
        paymentTotal: json["payment_total"],
        //comments: json["comments"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        //"service_id": serviceId,
        "payment_concept_id": paymentConceptId,
        "payment_concept": paymentConcept,
        //"total_used": totalUsed,
        "payment_total": paymentTotal,
        //"comments": comments,
      };
  final storage = const FlutterSecureStorage();

  Future<http.Response> insertImport(
      int serviceId, int conceptId, dynamic importTotal, comentary) async {
    String? token;
    token = await storage.read(key: 'token');

    Map data = {
      "service_id": serviceId,
      "token": token,
      "money_check_id": conceptId,
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

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Ha ocurrido un error al insertar el concepto');
    }
  }

  Future<List<TravelExpenses>> getData(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    String? token;
    token = await storage.read(key: 'token');


    final response = await http.get(
      Uri.parse('${baseURL}index.php').replace(queryParameters: {
        'r': 'esegadi/getcomprobaciones',
        'id': userId.toString(),
        'id_remision': id.toString(),
        'token': token,
      }),
    );
   
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TravelExpenses.fromJson(json)).toList();
    } else {
      throw Exception('Ha ocurrido un error al consultar los viaticos');
    }
  }
}
