// To parse this JSON data, do
//
//     final detailService = detailServiceFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:segadi/view_model/globals.dart';
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
  final storage = const FlutterSecureStorage();
  Future<DetailService> getDetail(id) async {
    print(id);
    late String? token;

    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('id') ?? 0;
    token = await storage.read(key: 'token');
    var route = 'index.php';

    var response = await http.get(
      Uri.parse(baseURL + route).replace(
        queryParameters: {
          'r': 'esegadi/getdetalle',
          'id_remision': id.toString(),
          'token': token,
          'id': userId.toString(),
        },
      ),
    );
    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      var result = DetailService.fromJson(body);
      result.isEnableButton = false;

      //valido cuando se envia un estatus de soporte, activo el boton para continuar ruta
      // y el icono estatus soporte
      if (result.type == '') {
        result.statusSupportModal = 'begin';
      }
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

        //estatus botones modal bano, comer, dormir y gas
        result.isButtonEnabledBano = true;
        result.isButtonEnabledComer = false;
        result.isButtonEnabledDormir = false;
        result.isButtonEnabledGas = false;

        result.statusSupportModal = 'end';
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
        //estatus botones modal bano, comer, dormir y gas
        result.isButtonEnabledBano = false;
        result.isButtonEnabledComer = true;
        result.isButtonEnabledDormir = false;
        result.isButtonEnabledGas = false;

        result.statusSupportModal = 'end';
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

        //estatus botones modal bano, comer, dormir y gas
        result.isButtonEnabledBano = false;
        result.isButtonEnabledComer = false;
        result.isButtonEnabledDormir = true;
        result.isButtonEnabledGas = false;

        result.statusSupportModal = 'end';
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

        //estatus botones modal bano, comer, dormir y gas
        result.isButtonEnabledBano = false;
        result.isButtonEnabledComer = false;
        result.isButtonEnabledDormir = false;
        result.isButtonEnabledGas = true;

        result.statusSupportModal = 'end';
      }

      //termino validaciones icono estatus soporte y boton continuar ruta

      //se valida que la remision tenga un estatusId == 0, mandatoryStatusId == 0 y el check lis en null
      //para habilitar el check list
      if (result.statusId == 0 &&
          result.mandatoryStatusId == 0 &&
          result.list == null) {
        result.isEnableStatusSupport = false;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.isEnableCheckList = true;
        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;

        //con esta validacion activo el boton del estatus obligatorio para inicar ruta, considerando la cita de carga
        //como opcion
      } else if (result.statusId == 0 ||
          result.statusId == 1 &&
              result.mandatoryStatusId == 0 &&
              result.nextMandatoryStatusId == 2 &&
              result.list != null) {
        result.isEnableButton = true;
        result.isEnableStatusSupport = false;
        result.isEnableCheckList = false;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;

        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;

        //con esta validacion activo el boton de estatus obligatorio y el icono de estatus de soporte
      } else if (result.nextMandatoryStatusId! > 2 &&
          result.list != null &&
          result.type != "begin") {
        result.isEnableButton = true;
        result.isEnableStatusSupport = true;
        result.isEnableCheckList = false;
        result.isEnableTripClosure = false;
        result.pendingMoneyChecks = false;
        result.mandatoryStatusId = result.nextMandatoryStatusId;
        result.mandatoryStatus = result.nextMandatoryStatus;

        //con esta validacion valido que la remision este terminada tomando en cuenta los IDS 23 de ambos
        //parametros  y que el cierre de viaje no este cerrado(true).
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.nextMandatoryStatusId == 0 &&
          result.serviceClosed == false) {
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = true;
        result.pendingMoneyChecks = false;
        result.mandatoryStatus = result.status;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.mandatoryStatus;

        //con esta validacion bloqueo el icono cierre de viaje
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.nextMandatoryStatusId == 0 &&
          result.serviceClosed == true &&
          result.pendingMoneyChecks == true) {
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = false;
        result.pendingMoneyChecks = true;
        result.mandatoryStatus = result.status;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.mandatoryStatus;

        //con esta validacion desactivo el icono de viaticos y activo el icono cierre de viaje
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.remainingEvidences == 0 &&
          result.serviceClosed == true &&
          result.pendingMoneyChecks == false) {
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = false;
        result.pendingMoneyChecks = false;
        result.mandatoryStatus = result.status;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.mandatoryStatus;

        //con esta validacion valido que el cierre de viaje este realizado y la remision tenga viaticos
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.nextMandatoryStatusId == 0 &&
          result.serviceClosed == true &&
          result.pendingMoneyChecks == true) {
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = false;
        result.pendingMoneyChecks = true;
        result.mandatoryStatus = result.status;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.mandatoryStatus;
      } else if (result.statusId == 23 &&
          result.mandatoryStatusId == 23 &&
          result.nextMandatoryStatusId == 0 &&
          result.serviceClosed == true &&
          result.pendingMoneyChecks == false) {
        result.isEnableCheckList = false;
        result.isEnableStatusSupport = false;
        result.serviceClosed = false;
        result.pendingMoneyChecks = false;
        result.mandatoryStatus = result.status;

        result.mandatoryStatusId = result.mandatoryStatusId;
        result.mandatoryStatus = result.mandatoryStatus;
      }

      return result;
    } else {
      throw Exception('Failed to load detail');
    }
  }

  Future<http.Response> changeStatusService(int serviceId, int statusId) async {
    late String? token;
    token = await storage.read(key: 'token');

    Map data = {"service_id": serviceId, "status_id": statusId, "token": token};

    var body = json.encode(data);
    var url = Uri.parse('${baseURL}index.php?r=esegadi/estatuspost');
    http.Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    
    print(response.statusCode);

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Ha ocurrido un error al cambiar el estatus');
    }
  }

  Future<http.Response> changeStatusSupport(
      int serviceId, int statusId, String type) async {
    late String? token;
    token = await storage.read(key: 'token');

    

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

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception(
          'Ha ocurrido un error al seleccionar un estatus de soporte');
    }
  }
}
