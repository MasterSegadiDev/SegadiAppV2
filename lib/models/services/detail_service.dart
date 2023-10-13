// To parse this JSON data, do
//
//     final detailService = detailServiceFromJson(jsonString);

import 'dart:convert';

DetailService detailServiceFromJson(String str) =>
    DetailService.fromJson(json.decode(str));

String detailServiceToJson(DetailService data) => json.encode(data.toJson());

class DetailService {
  int id;
  String service;
  String senderBusinessName;
  final String senderRfc;
  final String senderPhoneNumber;
  final String senderStreet;
  final String senderOutdoorNumber;
  final String senderInteriorNumber;
  final String senderCountry;
  final String senderState;
  final String senderZipCode;
  final String recipientBusinessName;
  final String recipientRfc;
  final String recipientPhoneNumber;
  final String recipientStreet;
  final String recipientOutdoorNumber;
  final String recipientInteriorNumber;
  final String recipientCountry;
  final String recipientState;
  final String recipientZipCode;

  DetailService({
    required this.id,
    required this.service,
    required this.senderBusinessName,
    required this.senderRfc,
    required this.senderPhoneNumber,
    required this.senderStreet,
    required this.senderOutdoorNumber,
    required this.senderInteriorNumber,
    required this.senderCountry,
    required this.senderState,
    required this.senderZipCode,
    required this.recipientBusinessName,
    required this.recipientRfc,
    required this.recipientPhoneNumber,
    required this.recipientStreet,
    required this.recipientOutdoorNumber,
    required this.recipientInteriorNumber,
    required this.recipientCountry,
    required this.recipientState,
    required this.recipientZipCode,
  });

  factory DetailService.fromJson(Map<String, dynamic> json) => DetailService(
        id: json["id"],
        service: json["service"],
        senderBusinessName: json["sender_business_name"],
        senderRfc: json["sender_rfc"],
        senderPhoneNumber: json["sender_phone_number"],
        senderStreet: json["sender_street"],
        senderOutdoorNumber: json["sender_outdoor_number"],
        senderInteriorNumber: json["sender_interior_number"],
        senderCountry: json["sender_country"],
        senderState: json["sender_state"],
        senderZipCode: json["sender_zip_code"],
        recipientBusinessName: json["recipient_business_name"],
        recipientRfc: json["recipient_rfc"],
        recipientPhoneNumber: json["recipient_phone_number"],
        recipientStreet: json["recipient_street"],
        recipientOutdoorNumber: json["recipient_outdoor_number"],
        recipientInteriorNumber: json["recipient_interior_number"],
        recipientCountry: json["recipient_country"],
        recipientState: json["recipient_state"],
        recipientZipCode: json["recipient_zip_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "service": service,
        "sender_business_name": senderBusinessName,
        "sender_rfc": senderRfc,
        "sender_phone_number": senderPhoneNumber,
        "sender_street": senderStreet,
        "sender_outdoor_number": senderOutdoorNumber,
        "sender_interior_number": senderInteriorNumber,
        "sender_country": senderCountry,
        "sender_state": senderState,
        "sender_zip_code": senderZipCode,
        "recipient_business_name": recipientBusinessName,
        "recipient_rfc": recipientRfc,
        "recipient_phone_number": recipientPhoneNumber,
        "recipient_street": recipientStreet,
        "recipient_outdoor_number": recipientOutdoorNumber,
        "recipient_interior_number": recipientInteriorNumber,
        "recipient_country": recipientCountry,
        "recipient_state": recipientState,
        "recipient_zip_code": recipientZipCode,
      };
}
