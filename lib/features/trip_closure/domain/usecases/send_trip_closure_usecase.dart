import 'dart:typed_data';

import 'package:segadi/features/trip_closure/domain/trip_closure_repository.dart';

class SendTripClosureUseCase {
  final TripClosureRepository repository;

  SendTripClosureUseCase(this.repository);

  Future<void> execute({
    required int serviceId,
    required Uint8List pdfBytes,
  }) {
    return repository.sendTripClosure(
      id: serviceId,
      pdfBytes: pdfBytes,
    );
  }
}
