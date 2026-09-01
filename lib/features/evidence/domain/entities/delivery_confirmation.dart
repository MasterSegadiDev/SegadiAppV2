import 'dart:typed_data';

class DeliveryConfirmation {
  final String serviceRequestId;
  final Uint8List fileSignature;
  final String strDateTime;
  final String strReceiverName;

  const DeliveryConfirmation({
    required this.serviceRequestId,
    required this.fileSignature,
    required this.strDateTime,
    required this.strReceiverName,
  });
}
