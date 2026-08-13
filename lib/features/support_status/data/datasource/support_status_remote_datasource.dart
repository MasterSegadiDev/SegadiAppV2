import '../dto/support_status_dto.dart';

abstract class SupportStatusRemoteDatasource {
  Future<List<SupportStatusDto>> getSupportStatuses();

  Future<bool> sendSupportStatus({
    required String referralId,
    required String serviceRequestId,
    required String statusId,
  });
}
