import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:segadi/core/network/api_exceptions.dart';
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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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

  // Future<bool> sendTripClosure({
  //   required Uint8List pdfBytes,
  //   required int id,
  // }) async {
  //   isSending = true;
  //   notifyListeners();

  //   try {
  //     await repository.sendTripClosure(
  //       id: id,
  //       pdfBytes: pdfBytes,
  //     );
  //     images.clear();
  //     return true;
  //   } catch (_) {
  //     return false;
  //   } finally {
  //     isSending = false;
  //     notifyListeners();
  //   }
  // }

  Future<bool> sendTripClosure(
      {required Uint8List pdfBytes, required int id}) async {
    try {
      isSending = true;
      _errorMessage = null; // Limpiamos errores previos
      notifyListeners();

      await repository.sendTripClosure(id: id, pdfBytes: pdfBytes);

      isSending = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      isSending = false;
      // 📢 Aquí capturamos el mensaje de "evidencias cerradas"
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      isSending = false;
      _errorMessage = "Error inesperado al procesar el envío.";
      notifyListeners();
      return false;
    }
  }
}
