import '../../domain/entities/support_status_entity.dart';
import '../../domain/repositories/support_status_repository.dart';
import '../datasource/support_status_remote_datasource.dart';

class SupportStatusRepositoryImpl implements SupportStatusRepository {
  final SupportStatusRemoteDatasource remoteDatasource;

  SupportStatusRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<List<SupportStatusEntity>> getSupportStatuses() {
    return remoteDatasource.getSupportStatuses();
  }

  @override
  Future<bool> sendSupportStatus({
    required String referralId,
    required String serviceRequestId,
    required String statusId,
  }) {
    return remoteDatasource.sendSupportStatus(
      referralId: referralId,
      serviceRequestId: serviceRequestId,
      statusId: statusId,
    );
  }
}
