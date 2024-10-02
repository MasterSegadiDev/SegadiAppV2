// To parse this JSON data, do
//
//     final detailFinished = detailFinishedFromJson(jsonString);

import 'dart:convert';

DetailFinished detailFinishedFromJson(String str) =>
    DetailFinished.fromJson(json.decode(str));

String detailFinishedToJson(DetailFinished data) => json.encode(data.toJson());

class DetailFinished {
  int id;
  String service;
  String senderBusinessName;
  String senderName;
  String senderPhoneNumber;
  String senderStreet;
  String senderOutdoorNumber;
  String senderInteriorNumber;
  String senderCountry;
  String senderState;
  int senderZipCode;
  String recipientBusinessName;
  String recipientName;
  String recipientPhoneNumber;
  String recipientStreet;
  String recipientOutdoorNumber;
  String recipientInteriorNumber;
  String recipientCountry;
  String recipientState;
  int recipientZipCode;
  String? paymentTotal; //revisar
  String? allowanceTotal;
  String? allowanceChecked;
  String? allowanceDifference;
  bool userRoll;

  DetailFinished({
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
    required this.paymentTotal,
    required this.allowanceTotal,
    required this.allowanceChecked,
    required this.allowanceDifference,
    required this.userRoll,
  });

  factory DetailFinished.fromJson(Map<String, dynamic> json) => DetailFinished(
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
        paymentTotal: json["payment_total"],
        allowanceTotal: json["allowance_total"],
        allowanceChecked: json["allowance_checked"],
        allowanceDifference: json["allowance_difference"],
        userRoll: false,
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
        "payment_total": paymentTotal,
        "allowance_total": allowanceTotal,
        "allowance_checked": allowanceChecked,
        "allowance_difference": allowanceDifference,
      };
}
