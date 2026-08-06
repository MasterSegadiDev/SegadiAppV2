import '../entities/checklist_entity.dart';

abstract class ChecklistRepository {
  /// Obtiene el checklist de una remisión
  Future<ChecklistEntity> getChecklist(
    String referralId,
  );

  /// Guarda el checklist contestado
  Future<bool> sendChecklist(
    ChecklistEntity checklist,
  );
}
