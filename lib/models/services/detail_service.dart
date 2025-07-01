// To parse this JSON data, do
//
//     final detailService = detailServiceFromJson(jsonString);

import 'dart:convert';

import 'package:segadi/utils/global_variables.dart';
import 'package:segadi/viewmodels/login/user_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

DetailService detailServiceFromJson(String str) =>
    DetailService.fromJson(json.decode(str));

String detailServiceToJson(DetailService data) => json.encode(data.toJson());

class DetailService {
  int? id;
  String? service;
  String? senderBusinessName;
  String? senderName;
  String? senderPhoneNumber;
  String? senderStreet;
  String? senderOutdoorNumber;
  String? senderInteriorNumber;
  String? senderCountry;
  String? senderState;
  int? senderZipCode;
  String? recipientBusinessName;
  String? recipientName;
  String? recipientPhoneNumber;
  String? recipientStreet;
  String? recipientOutdoorNumber;
  String? recipientInteriorNumber;
  String? recipientCountry;
  String? recipientState;
  int? recipientZipCode;
  int? statusId;
  String? status;
  String? type;
  int? mandatoryStatusId;
  String? mandatoryStatus;
  int? nextMandatoryStatusId;
  String? nextMandatoryStatus;
  bool? isEnableButton;
  bool? statusSupport;
  int? statusSupportId;
  Map<String, bool>? list;
  bool? isEnableCheckList;
  bool? isEnableTripClosure;
  bool? isEnableRouteFinished;
  bool? isEnableStatusSupport;
  bool? isEnableContinueRute;
  bool? serviceClosed;
  int? remainingEvidences;
  bool? pendingMoneyChecks;
  String? statusSupportModal;

  bool? isButtonEnabledBano;
  bool? isButtonEnabledComer;
  bool? isButtonEnabledDormir;
  bool? isButtonEnabledGas;

  DetailService({
    this.id,
    this.service,
    this.senderBusinessName,
    this.senderName,
    this.senderPhoneNumber,
    this.senderStreet,
    this.senderOutdoorNumber,
    this.senderInteriorNumber,
    this.senderCountry,
    this.senderState,
    this.senderZipCode,
    this.recipientBusinessName,
    this.recipientName,
    this.recipientPhoneNumber,
    this.recipientStreet,
    this.recipientOutdoorNumber,
    this.recipientInteriorNumber,
    this.recipientCountry,
    this.recipientState,
    this.recipientZipCode,
    this.statusId,
    this.status,
    this.type,
    this.mandatoryStatusId,
    this.mandatoryStatus,
    this.nextMandatoryStatusId,
    this.nextMandatoryStatus,
    this.isEnableButton,
    this.statusSupport,
    this.statusSupportId,
    this.list,
    this.isEnableCheckList,
    this.isEnableTripClosure,
    this.isEnableRouteFinished,
    this.isEnableStatusSupport,
    this.serviceClosed,
    this.remainingEvidences,
    this.pendingMoneyChecks,
    this.isEnableContinueRute,
    this.statusSupportModal,
    this.isButtonEnabledBano,
    this.isButtonEnabledComer,
    this.isButtonEnabledDormir,
    this.isButtonEnabledGas,
  });

  factory DetailService.fromJson(Map<String, dynamic> json) => DetailService(
        id: json["id"],
        service: json["service"],
        senderBusinessName: json["sender_business_name"],
        senderName: json["sender_name"],
        senderPhoneNumber: json["sender_phone_number"],
        senderStreet: json["sender_street"],
        senderOutdoorNumber: json["sender_outdoor_number"],
        senderInteriorNumber: json["sender_interior_number"],
        senderCountry: json["sender_country"],
        senderState: json["sender_state"],
        senderZipCode: json["sender_zip_code"],
        recipientBusinessName: json["recipient_business_name"],
        recipientName: json["recipient_name"],
        recipientPhoneNumber: json["recipient_phone_number"],
        recipientStreet: json["recipient_street"],
        recipientOutdoorNumber: json["recipient_outdoor_number"],
        recipientInteriorNumber: json["recipient_interior_number"],
        recipientCountry: json["recipient_country"],
        recipientState: json["recipient_state"],
        recipientZipCode: json["recipient_zip_code"],
        statusId: json["status_id"],
        status: json['status'],
        type: json['type'],
        mandatoryStatusId: json["mandatory_status_id"],
        mandatoryStatus: json["mandatory_status"],
        nextMandatoryStatusId: json["next_mandatory_status_id"],
        nextMandatoryStatus: json["next_mandatory_status"],
        isEnableButton: true,
        statusSupport: false,
        statusSupportId: 0,
        list: json["list"] is Map
            ? Map.from(json["list"]).map((k, v) => MapEntry<String, bool>(k, v))
            : null,
        isEnableCheckList: true,
        isEnableTripClosure: false,
        isEnableRouteFinished: false,
        isEnableStatusSupport: false,
        serviceClosed: json["service_closed"],
        remainingEvidences: json["remaining_evidences"],
        pendingMoneyChecks: json["pending_money_checks"],
        isEnableContinueRute: false,
        isButtonEnabledBano: true,
        isButtonEnabledComer: true,
        isButtonEnabledDormir: true,
        isButtonEnabledGas: true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "service": service,
        "sender_business_name": senderBusinessName,
        "sender_name": senderName,
        "sender_phone_number": senderPhoneNumber,
        "sender_street": senderStreet,
        "sender_outdoor_number": senderOutdoorNumber,
        "sender_interior_number": senderInteriorNumber,
        "sender_country": senderCountry,
        "sender_state": senderState,
        "sender_zip_code": senderZipCode,
        "recipient_business_name": recipientBusinessName,
        "recipient_name": recipientName,
        "recipient_phone_number": recipientPhoneNumber,
        "recipient_street": recipientStreet,
        "recipient_outdoor_number": recipientOutdoorNumber,
        "recipient_interior_number": recipientInteriorNumber,
        "recipient_country": recipientCountry,
        "recipient_state": recipientState,
        "recipient_zip_code": recipientZipCode,
        "status_id": statusId,
        "status": status,
        "type": type,
        "mandatory_status_id": mandatoryStatusId,
        "mandatory_status": mandatoryStatus,
        "next_mandatory_status_id": nextMandatoryStatusId,
        "next_mandatory_status": nextMandatoryStatus,
        "is_enable_button": isEnableButton,
        "status_support": statusSupport,
        "statu_support_id": statusSupportId,
        "list": Map.from(list!).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "is_enable_checklist": isEnableCheckList,
        "is_enable_trip_closure": isEnableTripClosure,
        "is_enable_route_finished": isEnableRouteFinished,
        "is_enable_status_support": isEnableStatusSupport,
        "service_closed": serviceClosed,
        "remaining_evidences": remainingEvidences,
        "pending_money_checks": pendingMoneyChecks,
        "is_enable_continue_rute": isEnableContinueRute,
      };
}

class DetailServices {
  final String baseUrl = GlobalVariables.baseUrl;
  final Map<String, String> headers = GlobalVariables.headers;

  final String baseUrlAirbag = GlobalVariablesAirbag.baseUrl;
  final Map<String, String> headersAirbag = GlobalVariablesAirbag.headers;

  Future<DetailService> getDetail(id) async {
    String? token;

    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    token = prefs.getString('token');
    var route = 'index.php';

    var response = await http.get(
      Uri.parse(baseUrl + route).replace(
        queryParameters: {
          'r': 'esegadi/getdetalle',
          'id_remision': id.toString(),
          'token': token,
          'id': userId.toString(),
        },
      ),
    );
    // print('BODY DEL DETALLE:' + response.body);
    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      var result = DetailService.fromJson(body);
      result.isEnableButton = false;

      print('VALORES DEL LISTADO DEL CHECK LIST .... ${result.id}');
      print(
          'ESTATUS ID ${result.statusId}, MANDATORY ESTATUS ID ${result.mandatoryStatusId}');

      //valido cuando se envia un estatus de soporte, activo el boton para continuar ruta
      // y el icono estatus soporte
      // Validación de estado inicial
      if (result.type == '') {
        result.statusSupportModal = 'begin';
      }

// Validación: Si hay checklist, bloquearlo y habilitar botones de estatus
      if (result.list != null &&
          result.statusId == 2 &&
          result.mandatoryStatusId == 0) {
        print(
            'CHECKLIST DETECTADO - BLOQUEANDO CHECKLIST, HABILITANDO ESTATUS');
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = true;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.isEnableButton = true;

        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      }

// Validación para habilitar el checklist si no hay status ni checklist
      else if (result.statusId == 0 &&
          result.mandatoryStatusId == 0 &&
          result.list == null) {
        print('ESTÁS EN CHECKLIST ...');
        result.isEnableStatusSupport = false;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.isEnableCheckList = true;

        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      }

// Validación de inicio de ruta
      else if ((result.statusId == 0 || result.statusId == 1) &&
          result.mandatoryStatusId == 0 &&
          result.nextMandatoryStatusId == 2 &&
          result.list != null) {
        print('ESTÁS EN INICIO DE RUTA ...');
        result.isEnableButton = true;
        result.isEnableStatusSupport = false;
        result.isEnableCheckList = false;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;

        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      }

// Validación: Mostrar botón de estatus obligatorio y soporte
      else if (result.nextMandatoryStatusId! > 2 &&
          result.list != null &&
          result.type != "begin") {
        result.isEnableButton = true;
        result.isEnableStatusSupport = true;
        result.isEnableCheckList = false;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;

        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
      }

// Validaciones para estatus de soporte (agrupado 22, 24, 38, 39)
      if ([22, 24, 38, 39].contains(result.statusId) &&
          result.type == "begin") {
        result.isEnableButton = false;
        result.isEnableContinueRute = true;
        result.isEnableStatusSupport = true;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.isEnableCheckList = false;

        result.statusSupportId = result.statusId;
        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;
        result.statusSupportModal = 'end';

        result.isButtonEnabledBano = result.statusId == 24;
        result.isButtonEnabledComer = result.statusId == 22;
        result.isButtonEnabledDormir = result.statusId == 38;
        result.isButtonEnabledGas = result.statusId == 39;
      }

// Validaciones de remisión finalizada con diferentes condiciones
      else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.nextMandatoryStatusId == 0 &&
          result.serviceClosed == false) {
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = true;
        result.pendingMoneyChecks = false;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.status;
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.nextMandatoryStatusId == 0 &&
          result.serviceClosed == true &&
          result.pendingMoneyChecks == true) {
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = false;
        result.pendingMoneyChecks = true;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.status;
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.remainingEvidences == 0 &&
          result.serviceClosed == true &&
          result.pendingMoneyChecks == false) {
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = false;
        result.pendingMoneyChecks = false;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.status;
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.nextMandatoryStatusId == 0 &&
          result.serviceClosed == true &&
          result.pendingMoneyChecks == false) {
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = false;
        result.pendingMoneyChecks = false;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.status;
      }

      return result;
    } else {
      throw Exception('Failed to load detail');
    }
  }

  Future<http.Response> changeStatusService(int serviceId, int statusId) async {
    //String? token;
    //final prefs = await SharedPreferences.getInstance();
    final token = await LoginViewModel.getSavedToken();

    Map data = {"service_id": serviceId, "status_id": statusId, "token": token};

    var body = json.encode(data);
    var url = Uri.parse('${baseUrl}index.php?r=esegadi/estatuspost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    return response;
  }

  Future<http.Response> changeStatusOperatorAirbag(String status) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('number_employe') ?? 0;

    print('NUMERO DE EMPLEADO:' + userId.toString());

    Map data = {"force": status};

    var body = json.encode(data);
    var url =
        Uri.parse('${GlobalVariablesAirbag.baseUrl}$userId/changeAppStatus');

    print('URL AIR BAG: $url');

    http.Response response = await http.post(
      url,
      headers: GlobalVariablesAirbag.headers,
      body: body,
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  }

  Future<http.Response> changeStatusSupport(
      int serviceId, int statusId, String type) async {
    String? token;
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    Map data = {
      "service_id": serviceId,
      "status_id": statusId,
      "type": type,
      "token": token
    };

    var body = json.encode(data);
    var url = Uri.parse('${baseUrl}index.php?r=esegadi/estatus-soportepost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    return response;
  }
}
