import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:segadi/utils/global_variables.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
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
  bool? pendingMoneyChecks;

  TravelExpenses({
    this.id,
    //this.serviceId,
    this.paymentConceptId,
    this.paymentConcept,
    //this.totalUsed,
    this.paymentTotal,
    //this.comments,
    this.import,
    this.pendingMoneyChecks,
  });

  factory TravelExpenses.fromJson(Map<String, dynamic> json) => TravelExpenses(
        id: json["id"],
        //serviceId: json["service_id"],
        paymentConceptId: json["payment_concept_id"],
        paymentConcept: json["payment_concept"],
        //totalUsed: json["total_used"],
        paymentTotal: json["payment_total"],
        //comments: json["comments"],
        pendingMoneyChecks: json["pending_money_checks"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        //"service_id": serviceId,
        "payment_concept_id": paymentConceptId,
        "payment_concept": paymentConcept,
        //"total_used": totalUsed,
        "payment_total": paymentTotal,
        "pending_money_checks": pendingMoneyChecks,
        //"comments": comments,
      };

  final String baseUrl = GlobalVariables.baseUrl;
  final Map<String, String> headers = GlobalVariables.headers;

  Future<Object> insertImport(int serviceId, int conceptId, dynamic importTotal,
      comentary, String name, String? imageBytes) async {
    final prefs = await SharedPreferences.getInstance();
    String? token;
    token = prefs.getString('token');

    Map data = {
      "service_id": serviceId,
      "token": token,
      "money_check_id": conceptId,
      "total_used": importTotal,
      "comments": comentary,
      "document_name": name,
      "document": imageBytes,
    };

    var body = json.encode(data);
    var url = Uri.parse(
        '${GlobalVariables.baseUrl}index.php?r=esegadi/comprobacionespost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(
        'ESTATUS DE RESPUESTA INSERT IMPORT:' + response.statusCode.toString());
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      //  print('BODY DETALLE: ${response.body}');
      final result = TravelExpenses.fromJson(body);

      if (result.pendingMoneyChecks == false) {
        final c = await close(serviceId);
        if (c == true) {
          print('se cerro el servicio y regresando al detalle');
          return true;
        }
      } else if (result.pendingMoneyChecks == true) {
        return false;
      }

      return false;
    } else {
      throw Exception('Ha ocurrido un error al insertar el concepto');
    }
  }

  Future<List<TravelExpenses>> getData(int remition_id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    String? token;
    token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${GlobalVariables.baseUrl}index.php')
          .replace(queryParameters: {
        'r': 'esegadi/getcomprobaciones',
        'id': userId.toString(),
        'id_remision': GlobalVariables.serviceDetailId.toString(),
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

  Future<bool> close(int serviceId) async {
    final token = await LoginViewModel.getSavedToken();

    if (token == null) {
      throw Exception("Token no disponible");
    }

    final Map<String, dynamic> data = {
      "service_id": serviceId,
      "token": token,
      "close": 1,
    };

    final url = Uri.parse('${baseUrl}index.php?r=esegadi/cierreevidenciaspost');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Error al cerrar el viaje (status: ${response.statusCode})');
    }

    return true;
  }
}
