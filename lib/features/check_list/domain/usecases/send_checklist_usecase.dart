import '../entities/checklist_entity.dart';
import '../repositories/checklist_repository.dart';

class SendChecklistUseCase {
  final ChecklistRepository repository;

  SendChecklistUseCase(
    this.repository,
  );

  Future<bool> call(
    ChecklistEntity checklist,
  ) {
    return repository.sendChecklist(
      checklist,
    );
  }
}
