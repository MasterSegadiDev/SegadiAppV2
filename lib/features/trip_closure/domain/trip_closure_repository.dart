import 'dart:typed_data';

abstract class TripClosureRepository {
  Future<void> sendTripClosure({
    required int id,
    required Uint8List pdfBytes,
  });
}
