import '../entities/support_status_entity.dart';
import '../repositories/support_status_repository.dart';

class GetSupportStatusUseCase {
  final SupportStatusRepository repository;

  GetSupportStatusUseCase({
    required this.repository,
  });

  Future<List<SupportStatusEntity>> call() {
    return repository.getSupportStatuses();
  }
}
