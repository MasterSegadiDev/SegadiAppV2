import 'dart:typed_data';
import 'package:segadi/features/trip_closure_old/data/datasources/trip_closure_remote_datasource.dart';
import 'package:segadi/features/trip_closure_old/domain/trip_closure_repository.dart';

class TripClosureRepositoryImpl implements TripClosureRepository {
  final TripClosureRemoteDataSource remote;

  TripClosureRepositoryImpl(this.remote);

  @override
  Future<void> sendTripClosure({
    required int id,
    required Uint8List pdfBytes,
  }) {
    return remote.send(id, pdfBytes);
  }
}
