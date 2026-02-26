import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/features/check_list/data/repositories/checklist_repository_impl.dart';
import 'package:segadi/features/check_list/domain/entities/checklist_item_entity.dart';

class ChecklistViewModel extends ChangeNotifier {
  final ChecklistRepositoryImpl repo;
  final int serviceId;

  ChecklistViewModel({
    required this.repo,
    required this.serviceId,
  }) {
    // Es mejor llamar al load aquí para que cargue al abrir la modal
    load();
  }

  List<ChecklistItemEntity> items = [];
  bool loading = false;
  String? errorMessage;

  /// Obtiene el token de forma segura
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  /// Carga el catálogo de opciones
  Future<void> load() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    final token = await _getToken();
    final result = await repo.getChecklistCatalog(token);

    result.fold(
      (failure) {
        errorMessage = failure.message;
        items = [];
      },
      (entities) {
        items = entities;
      },
    );

    loading = false;
    notifyListeners();
  }

  /// Cambia el estado de selección de un item
  void toggle(int id) {
    try {
      final index = items.indexWhere((e) => e.id == id);
      if (index != -1) {
        items[index].checked = !items[index].checked;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error en toggle: $e");
    }
  }

  /// Getter para habilitar/deshabilitar el botón en la UI
  bool get isValid => items.any((e) => e.checked);

  /// Guarda los IDs seleccionados
  Future<bool> save() async {
    // 1. Obtenemos solo los seleccionados
    final checkedIds = items.where((e) => e.checked).map((e) => e.id).toList();

    if (checkedIds.isEmpty) {
      errorMessage = "Selecciona al menos una opción";
      notifyListeners();
      return false;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    final token = await _getToken();

    // 2. Llamada al repositorio
    final result = await repo.saveChecklist(
      serviceId: serviceId,
      ids: checkedIds,
      token: token,
    );

    return result.fold(
      (failure) {
        errorMessage = failure.message;
        loading = false;
        notifyListeners();
        return false;
      },
      (success) {
        loading = false;
        notifyListeners();
        return true; // Éxito: La UI cerrará la modal
      },
    );
  }
}
