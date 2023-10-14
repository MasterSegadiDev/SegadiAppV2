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
      };
}
