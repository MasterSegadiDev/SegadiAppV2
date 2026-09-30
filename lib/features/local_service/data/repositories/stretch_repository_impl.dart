import 'package:segadi/features/local_service/data/datasources/stretch_remote_data_source.dart';
import 'package:segadi/features/local_service/domain/entities/stretch.dart';
import 'package:segadi/features/local_service/domain/repositories/stretch_repository.dart';

import '../../domain/enums/tramo_status.dart';

class TramoRepositoryImpl implements TramoRepository {
  final TramoRemoteDataSource remoteDataSource;

  TramoRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Tramo?> getActiveTramo(
    String operadorId,
  ) {
    return remoteDataSource.getActiveTramo(
      operadorId,
    );
  }

  @override
  Future<void> updateStatus({
    required String referralId,
    required int tramoIndex,
    required TramoStatus status,
  }) {
    return remoteDataSource.updateStatus(
      referralId: referralId,
      tramoIndex: tramoIndex,
      status: status,
    );
  }
}
