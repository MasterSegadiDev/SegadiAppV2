import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:segadi/core/errors/failure.dart';
import 'package:segadi/features/evidence/domain/repositories/evidence_repository.dart';

class SendEvidenceUseCase {
  final EvidenceRepository repository;

  SendEvidenceUseCase(this.repository);

  Future<bool> execute({
    required int serviceId,
    required Uint8List pdfBytes,
    required Uint8List signatureBytes,
    required String receiverName,
    required DateTime receiverDate,
  }) async {
    await repository.sendPdf(
      serviceId: serviceId,
      pdfBytes: pdfBytes,
      receiverName: receiverName,
      receiverDate: receiverDate,
    );

    await repository.sendSignature(
      serviceId: serviceId,
      signatureBytes: signatureBytes,
      receiverName: receiverName,
      receiverDate: receiverDate,
    );

    return true;
  }
}
