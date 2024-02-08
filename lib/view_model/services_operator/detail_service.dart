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
    print(id);
    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getdetalle',
      'id_remision': id.toString(),
      'token': token,
      'id': userId.toString(),
    }));

    if (response.statusCode == 200) {
      var result = DetailService.fromJson(json.decode(response.body));
      result.isEnableButton = false;

      if (result.statusId == 24 && result.type == "begin") {
        result.isEnableButton = false;
        result.isEnableContinueRute = true;

        result.isEnableStatusSupport = true;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.isEnableCheckList = false;

        result.statusSupportId = 24;
        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      }
      if (result.statusId == 22 && result.type == "begin") {
        result.isEnableButton = false;
        result.isEnableContinueRute = true;

        result.isEnableStatusSupport = true;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.isEnableCheckList = false;

        result.statusSupportId = 22;
        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      }
      if (result.statusId == 38 && result.type == "begin") {
        result.isEnableButton = false;
        result.isEnableContinueRute = true;

        result.isEnableStatusSupport = true;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.isEnableCheckList = false;

        result.statusSupportId = 38;
        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      }
      if (result.statusId == 39 && result.type == "begin") {
        result.isEnableButton = false;
        result.isEnableContinueRute = true;

        result.statusSupportId = 39;
        result.isEnableStatusSupport = true;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.isEnableCheckList = false;

        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      }

      //habilitar check list y deshabilitar los demas botones
      if (result.statusId == 0 &&
          result.mandatoryStatusId == 0 &&
          result.list == null) {
        result.isEnableStatusSupport = false;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.isEnableCheckList = true;
        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      } else if (result.statusId == 0 &&
          result.mandatoryStatusId == 0 &&
          result.nextMandatoryStatusId == 2 &&
          result.list != null) {
        print('entraste a activar el boton');
        result.isEnableButton = true;
        result.isEnableStatusSupport = false;
        result.isEnableCheckList = false;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;

        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      } else if (result.nextMandatoryStatusId! > 2 &&
          result.list != null &&
          result.type != "begin") {
        print(
            'entro a status mayor a 2 y activar boton y icono status soporte');
        result.isEnableButton = true;
        result.isEnableStatusSupport = true;
        result.isEnableCheckList = false;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.nextMandatoryStatusId == 0 &&
          result.serviceClosed == false) {
        print('entraste a bloquear service closed false');
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = true;
        result.pendingMoneyChecks = false;
        result.mandatoryStatus = result.status;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.mandatoryStatus;
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.nextMandatoryStatusId == 0 &&
          result.serviceClosed == true) {
        print('entraste a bloquear service closed true');
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = false;
        result.pendingMoneyChecks = false;
        result.mandatoryStatus = result.status;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.mandatoryStatus;
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.remainingEvidences == 0 &&
          result.serviceClosed == true &&
          result.pendingMoneyChecks == false) {
        print('entraste a bloquear viaticos con false');

        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = true;
        result.pendingMoneyChecks = false;
        result.mandatoryStatus = result.status;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.mandatoryStatus;
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.serviceClosed == true &&
          result.pendingMoneyChecks == false) {
        print('entraste para ver los viaticos');

        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = false;
        result.pendingMoneyChecks = true;
        result.mandatoryStatus = result.status;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.mandatoryStatus;
      }

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
      int id, String serviceId, String image, String extension) async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    Map data = {
      "service_id": id,
      "token": token,
      "document_name": serviceId + extension,
      "document_description": "Evidencia Operador",
      "document_type": "POD Operador",
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

  Future getPdf(serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getcfdi',
      'token': token,
      'id': userId.toString(),
      'service_id': serviceId.toString(),
    }));
    var data = jsonDecode(response.body.toString());
  }

  Future getEvidentias(serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    var token = prefs.getString('token') ?? '';
    var route = 'index.php';

    var response =
        await http.get(Uri.parse(baseURL + route).replace(queryParameters: {
      'r': 'esegadi/getevidenciasfaltantes',
      'token': token,
      'id': userId.toString(),
      'service_id': serviceId.toString(),
    }));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      return data;
    }
  }

  closeTravel(serviceId) async {
    final prefs = await SharedPreferences.getInstance();

    var token = prefs.getString('token') ?? '';

    Map data = {
      "service_id": serviceId,
      "token": token,
      "close": 1,
    };

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/cierreevidenciaspost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response;
  }
}
