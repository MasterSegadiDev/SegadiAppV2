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
  final int? id;
  final String? service;
  final String? senderBusinessName;
  final String? senderName;
  final String? senderPhoneNumber;
  final String? senderStreet;
  final String? senderOutdoorNumber;
  final String? senderInteriorNumber;
  final String? senderCountry;
  final String? senderState;
  final int? senderZipCode;
  final String? recipientBusinessName;
  final String? recipientName;
  final String? recipientPhoneNumber;
  final String? recipientStreet;
  final String? recipientOutdoorNumber;
  final String? recipientInteriorNumber;
  final String? recipientCountry;
  final String? recipientState;
  final int? recipientZipCode;
  int? statusId;
  String? status;
  final String? type;
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
  final int? remainingEvidences;
  bool? pendingMoneyChecks;

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
      return DetailService.fromJson(body);
    } else {
      throw Exception('Failed to load service');
    }
  }
}
