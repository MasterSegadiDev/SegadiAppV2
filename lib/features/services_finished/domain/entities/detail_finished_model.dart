class DetailFinished {
  final String service;
  final String senderBusinessName;
  final String senderPhoneNumber;
  final String senderName;
  final String senderStreet;
  final String senderOutdoorNumber;
  final String senderZipCode;
  final String recipientBusinessName;
  final String recipientPhoneNumber;
  final String recipientName;
  final String recipientStreet;
  final String recipientOutdoorNumber;
  final String recipientZipCode;
  final String recipientState;
  final String paymentTotal;
  final String allowanceChecked;
  final String allowanceDifference;
  bool userRoll; // Para controlar la visibilidad de comisiones

  DetailFinished({
    required this.service,
    required this.senderBusinessName,
    required this.senderPhoneNumber,
    required this.senderName,
    required this.senderStreet,
    required this.senderOutdoorNumber,
    required this.senderZipCode,
    required this.recipientBusinessName,
    required this.recipientPhoneNumber,
    required this.recipientName,
    required this.recipientStreet,
    required this.recipientOutdoorNumber,
    required this.recipientZipCode,
    required this.recipientState,
    required this.paymentTotal,
    required this.allowanceChecked,
    required this.allowanceDifference,
    this.userRoll = false,
  });

  factory DetailFinished.fromJson(Map<String, dynamic> json) => DetailFinished(
        service: json["service"] ?? '',
        senderBusinessName: json["sender_business_name"] ?? '',
        senderPhoneNumber: json["sender_phone_number"] ?? '',
        senderName: json["sender_name"] ?? '',
        senderStreet: json["sender_street"] ?? '',
        senderOutdoorNumber: json["sender_outdoor_number"] ?? '',
        senderZipCode: json["sender_zip_code"] ?? '',
        recipientBusinessName: json["recipient_business_name"] ?? '',
        recipientPhoneNumber: json["recipient_phone_number"] ?? '',
        recipientName: json["recipient_name"] ?? '',
        recipientStreet: json["recipient_street"] ?? '',
        recipientOutdoorNumber: json["recipient_outdoor_number"] ?? '',
        recipientZipCode: json["recipient_zip_code"] ?? '',
        recipientState: json["recipient_state"] ?? '',
        paymentTotal: json["payment_total"]?.toString() ?? '0.00',
        allowanceChecked: json["allowance_checked"]?.toString() ?? '0.00',
        allowanceDifference: json["allowance_difference"]?.toString() ?? '0.00',
      );
}
