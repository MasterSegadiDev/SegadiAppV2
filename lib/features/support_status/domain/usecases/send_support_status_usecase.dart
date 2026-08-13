import '../repositories/support_status_repository.dart';

class SendSupportStatusUseCase {
  final SupportStatusRepository repository;

  SendSupportStatusUseCase({
    required this.repository,
  });

  Future<bool> call({
    required String referralId,
    required String serviceRequestId,
    required String statusId,
  }) async {
    return repository.sendSupportStatus(
      referralId: referralId,
      serviceRequestId: serviceRequestId,
      statusId: statusId,
    );
  }
}
