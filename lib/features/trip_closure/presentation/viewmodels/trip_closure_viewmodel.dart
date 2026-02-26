import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:segadi/features/trip_closure/domain/services/document_scanner.dart';
import 'package:segadi/features/trip_closure/domain/trip_closure_repository.dart';
import 'package:segadi/features/trip_closure/pdf/trip_pdf_generator.dart';

class TripClosureViewModel extends ChangeNotifier {
  final int id;
  final String serviceId;
  final TripClosureRepository repository;
  final DocumentScanner scanner;

  TripClosureViewModel({
    required this.repository,
    required this.scanner,
    required this.id,
    required this.serviceId,
  });

  final List<Uint8List> images = [];
  bool isSending = false;

  void removeImage(int index) {
    images.removeAt(index);
    notifyListeners();
  }

  Future<void> captureImage() async {
    final image = await scanner.scan();
    if (image != null) {
      images.add(image);
      notifyListeners();
    }
  }

  Future<Uint8List> generatePdf() async {
    return TripPdfGenerator.generate(images);
  }

  Future<bool> sendTripClosure({
    required Uint8List pdfBytes,
    required int id,
  }) async {
    isSending = true;
    notifyListeners();

    try {
      await repository.sendTripClosure(
        id: id,
        pdfBytes: pdfBytes,
      );
      images.clear();
      return true;
    } catch (_) {
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }
}
