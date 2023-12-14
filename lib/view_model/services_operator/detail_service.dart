import 'dart:convert';
import 'dart:developer';

import 'package:segadi/model/services/checklist.dart';
import 'package:segadi/model/services/detail_service.dart';
import 'package:segadi/view_model/globals.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Detail {
  Future<DetailService>? getService(int id) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getdetalle',
      'id_remision': id.toString(),
      'token': token,
      'id': userId.toString(),
    }));
    if (response.statusCode == 200) {
      var result = DetailService.fromJson(json.decode(response.body));
      if (result.statusId == 24 && result.type == "begin" ||
          result.statusId == 22 && result.type == "begin" ||
          result.statusId == 38 && result.type == "begin" ||
          result.statusId == 39 && result.type == "begin") {
        result.isEnableButton = false;
        result.mandatoryStatus = result.status;
      }

      if (result.nextMandatoryStatusId != 0) {
        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      }

      if (result.statusId != 0 && result.mandatoryStatusId != 0) {
        result.isEnableStatusSupport = true;
      }

      if (result.list == null) {
        result.isEnableButton = false;
      }

      if (result.list != null) {
        result.isEnableCheckList = false;
      }

      if (result.statusId == 23) {
        result.isEnableTripClosure = true;
      }
      if (result.statusId == 23) {
        result.isEnableRouteFinished = true;
      }

      if (result.statusId == 24) {
        result.statusSupportId = 24;
        result.statusSupport = true;
      } else if (result.statusId == 22) {
        result.statusSupportId = 22;
        result.statusSupport = true;
      } else if (result.statusId == 38) {
        result.statusSupportId = 38;
        result.statusSupport = true;
      } else if (result.statusId == 39) {
        result.statusSupportId = 39;
        result.statusSupport = true;
      } else {
        result.statusSupportId = 0;
        result.statusSupport = false;
      }

      if (result.statusId == 23) {
        result.isEnableButton = false;
      }

      print(inspect(result));
      return result;
    } else {
      throw Exception('Failed to load detail');
    }
  }

  Future<List<CheckList>> getCheckList() async {
    String token;
    List<CheckList> serviceList = [];

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response = await http
        .get(Uri.parse(baseURL + route).replace(queryParameters: {
          'r': 'esegadi/get-puntosrevision',
          'token': token,
        }))
        .timeout(const Duration(seconds: 90));
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      for (Map<String, dynamic> index in data) {
        serviceList.add(CheckList.fromJson(index));
      }

      return serviceList;
    } else {
      return serviceList;
    }
  }

  static Future<http.Response> addOption(
      int id, Map<dynamic, dynamic> array) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    Map data = {
      "service": {"service_id": id, "list": array},
      "token": token
    };
    var body = json.encode(data);

    var url = Uri.parse('${baseURL}index.php?r=esegadi/checklistpost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response;
  }

  static Future<http.Response> addStatus(int serviceId, int statusId) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    Map data = {"service_id": serviceId, "status_id": statusId, "token": token};

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/estatuspost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    print(inspect(response.body));
    return response;
  }

  static Future<http.Response> addStatusSupport(
      int serviceId, int statusId, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    Map data = {
      "service_id": serviceId,
      "status_id": statusId,
      "type": type,
      "token": token
    };

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/estatus-soportepost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    return response;
  }

  static Future<http.Response> insertImageTripClosure(
      int serviceId, String image, String serviceIdExtension) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    Map data = {
      "service_id": serviceId,
      "token": token,
      "document_name": serviceIdExtension,
      "document_description": "uso de imagenes con show modal",
      "document_type": "POD",
      "document": image,
    };

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/evidenciaspost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    return response;
  }
}
