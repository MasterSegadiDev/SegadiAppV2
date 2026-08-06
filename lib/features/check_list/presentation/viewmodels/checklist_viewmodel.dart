import 'package:flutter/material.dart';

import '../../domain/entities/checklist_entity.dart';
import '../../domain/entities/checklist_checkpoint_entity.dart';

import '../../domain/usecases/get_checklist_usecase.dart';
import '../../domain/usecases/send_checklist_usecase.dart';

class ChecklistViewModel extends ChangeNotifier {
  final GetChecklistUseCase getChecklistUseCase;
  final SendChecklistUseCase sendChecklistUseCase;

  ChecklistViewModel({
    required this.getChecklistUseCase,
    required this.sendChecklistUseCase,
  });

  bool isLoading = false;
  bool isSaving = false;

  /// Evita modificaciones después de un guardado exitoso
  bool submitted = false;

  String? error;

  ChecklistEntity? checklist;

  List<ChecklistCheckpointEntity> get checkpoints =>
      checklist?.checkpoints ?? [];

  Future<void> loadChecklist(
    String referralId,
  ) async {
    try {
      isLoading = true;
      error = null;

      notifyListeners();

      checklist = await getChecklistUseCase(
        referralId,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleCheckpoint(
    String checkpointId,
    bool value,
  ) {
    if (submitted) return;

    if (checklist == null) return;

    final updated = checklist!.checkpoints.map(
      (item) {
        if (item.id != checkpointId) {
          return item;
        }

        return item.copyWith(
          result: value,
        );
      },
    ).toList();

    checklist = checklist!.copyWith(
      checkpoints: updated,
    );

    notifyListeners();
  }

  Future<bool> saveChecklist() async {
    /// Evita doble envío
    if (isSaving) {
      return false;
    }

    /// Limpia error anterior
    error = null;

    /// Debe existir checklist
    if (checklist == null) {
      error = 'No existe información del checklist.';
      notifyListeners();
      return false;
    }

    /// Debe contener checkpoints
    if (checklist!.checkpoints.isEmpty) {
      error = 'No existen checkpoints para guardar.';
      notifyListeners();
      return false;
    }

    /// Debe existir al menos uno marcado
    if (!hasCheckedItem) {
      error = 'Debe seleccionar al menos un checkpoint.';
      notifyListeners();
      return false;
    }

    try {
      isSaving = true;

      notifyListeners();

      final success = await sendChecklistUseCase(
        checklist!,
      );

      if (success) {
        submitted = true;
      }

      return success;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  bool get hasCheckedItem {
    if (checklist == null) return false;

    return checklist!.checkpoints.any(
      (e) => e.result,
    );
  }

  bool get allChecked {
    if (checklist == null) return false;

    return checklist!.checkpoints.every(
      (e) => e.result,
    );
  }
}
