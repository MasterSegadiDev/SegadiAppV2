// To parse this JSON data, do
//
//     final detailService = detailServiceFromJson(jsonString);

import 'dart:convert';

DetailService detailServiceFromJson(String str) =>
    DetailService.fromJson(json.decode(str));

String detailServiceToJson(DetailService data) => json.encode(data.toJson());

class DetailService {
  final int id;
  final String service;
  final String senderBusinessName;
  final String senderName;
  final String senderPhoneNumber;
  final String senderStreet;
  final String senderOutdoorNumber;
  final String senderInteriorNumber;
  final String senderCountry;
  final String senderState;
  final int senderZipCode;
  final String recipientBusinessName;
  final String recipientName;
  final String recipientPhoneNumber;
  final String recipientStreet;
  final String recipientOutdoorNumber;
  final String recipientInteriorNumber;
  final String recipientCountry;
  final String recipientState;
  final int recipientZipCode;
  int? statusId;
  String? status;
  final String? type;
  int? mandatoryStatusId;
  String? mandatoryStatus;
  int? nextMandatoryStatusId;
  String? nextMandatoryStatus;
  bool isEnableButton;
  bool? statusSupport;
  int statusSupportId;
  Map<String, bool>? list;
  bool isEnableCheckList;
  bool isEnableTripClosure;
  bool isEnableRouteFinished;
  bool isEnableStatusSupport;
  final bool serviceClosed;
  final int remainingEvidences;

  DetailService({
    required this.id,
    required this.service,
    required this.senderBusinessName,
    required this.senderName,
    required this.senderPhoneNumber,
    required this.senderStreet,
    required this.senderOutdoorNumber,
    required this.senderInteriorNumber,
    required this.senderCountry,
    required this.senderState,
    required this.senderZipCode,
    required this.recipientBusinessName,
    required this.recipientName,
    required this.recipientPhoneNumber,
    required this.recipientStreet,
    required this.recipientOutdoorNumber,
    required this.recipientInteriorNumber,
    required this.recipientCountry,
    required this.recipientState,
    required this.recipientZipCode,
    required this.statusId,
    required this.status,
    required this.type,
    required this.mandatoryStatusId,
    required this.mandatoryStatus,
    required this.nextMandatoryStatusId,
    required this.nextMandatoryStatus,
    required this.isEnableButton,
    this.statusSupport,
    required this.statusSupportId,
    this.list,
    required this.isEnableCheckList,
    required this.isEnableTripClosure,
    required this.isEnableRouteFinished,
    required this.isEnableStatusSupport,
    required this.serviceClosed,
    required this.remainingEvidences,
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
      };
}
