import '../entities/support_status_entity.dart';

abstract class SupportStatusRepository {
  Future<List<SupportStatusEntity>> getSupportStatuses();

  Future<bool> sendSupportStatus({
    required String referralId,
    required String serviceRequestId,
    required String statusId,
  });
}
