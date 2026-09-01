import 'dart:convert';
import 'dart:typed_data';
import 'package:segadi/features/evidence_old/data/datasources/evidence_remote_datasource.dart';
import 'package:segadi/features/evidence_old/domain/repositories/evidence_repository.dart';

import 'package:flutter/foundation.dart';

class EvidenceRepositoryImpl implements EvidenceRepository {
  final EvidenceRemoteDataSource remote;

  EvidenceRepositoryImpl(this.remote);

  @override
  Future<void> sendPdf({
    required int serviceId,
    required Uint8List pdfBytes,
    required String receiverName,
    required DateTime receiverDate,
  }) async {
    // final token = await LoginViewModel.getSavedToken();
    final token = '1234567890';
    if (token == null || token.isEmpty) {
      throw Exception('Token no encontrado');
    }

    await remote.postEvidence({
      "service_id": serviceId.toString(),
      "token": token,
      "receiver_name": '',
      "receiver_date": '',
      "file_type": "pdf",
      "document_name": "Evidencia",
      "document_type": "POD Operador",
      "document_description": "POD Operador",
      "document": base64Encode(pdfBytes),
    });
  }

  @override
  Future<void> sendSignature({
    required int serviceId,
    required Uint8List signatureBytes,
    required String receiverName,
    required DateTime receiverDate,
  }) async {
    //final token = await LoginViewModel.getSavedToken();
    final token = '1234567890';
    if (token == null || token.isEmpty) {
      throw Exception('Token no encontrado');
    }

    if (signatureBytes.length == 0 || signatureBytes.isEmpty) {
      print('la firma viene en null ${signatureBytes.length}');
      return;
    }

    await remote.postEvidence({
      "service_id": serviceId.toString(),
      "token": token,
      "receiver_name": receiverName,
      "receiver_date": receiverDate.toIso8601String(),
      "file_type": "png",
      "document_name": "Firma",
      "document_type": "Firma",
      "document_description": "Firma",
      "document": base64Encode(signatureBytes),
    });
  }
}
