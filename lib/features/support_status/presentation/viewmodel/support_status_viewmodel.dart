import 'package:flutter/material.dart';
import 'package:segadi/features/support_status/data/repositories/support_status_repository_impl.dart';
import 'package:segadi/features/support_status/domain/entities/support_status_entity.dart';

class SupportStatusViewModel extends ChangeNotifier {
  final SupportStatusRepositoryImpl repo;
  final int serviceId;

  int statusId;
  String type; // 'begin' | 'end' | ''
  bool loading = false;
  String? errorMessage;

  SupportStatusViewModel({
    required this.repo,
    required this.serviceId,
    required this.statusId,
    required this.type,
  });

  final options = const [
    SupportStatusEntity(id: 24, label: 'Baño', icon: Icons.wc),
    SupportStatusEntity(id: 22, label: 'Comer', icon: Icons.restaurant),
    SupportStatusEntity(id: 38, label: 'Dormir', icon: Icons.hotel),
    SupportStatusEntity(
        id: 39, label: 'Gasolina', icon: Icons.local_gas_station),
  ];

  bool get hasActive => type == 'begin';
  bool isSelected(int id) => hasActive && statusId == id;

  /// 🔹 Tap handler (BEGIN / END) con manejo de errores Clean
  Future<bool> send(int id) async {
    if (loading) return false;

    if (hasActive && statusId != id) {
      errorMessage = 'Debes finalizar el apoyo actual primero';
      notifyListeners();
      return false;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newType = hasActive ? 'end' : 'begin';

      await repo.sendStatus(
        serviceId: serviceId,
        statusId: id,
        type: newType,
      );

      // Éxito: Actualizamos estado local
      statusId = id;
      type = newType;
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception:', '').trim();
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
