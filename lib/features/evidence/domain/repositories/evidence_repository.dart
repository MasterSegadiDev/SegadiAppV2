import 'dart:typed_data';

abstract class EvidenceRepository {
  Future<void> sendPdf({
    required int serviceId,
    required Uint8List pdfBytes,
    required String receiverName,
    required DateTime receiverDate,
  });

  Future<void> sendSignature({
    required int serviceId,
    required Uint8List signatureBytes,
    required String receiverName,
    required DateTime receiverDate,
  });
}
