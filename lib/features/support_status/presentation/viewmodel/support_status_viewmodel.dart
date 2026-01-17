import 'package:flutter/material.dart';
import 'package:segadi/features/support_status/data/repositories/support_status_repository_impl.dart';
import 'package:segadi/features/support_status/domain/entities/support_status_entity.dart';

class SupportStatusViewModel extends ChangeNotifier {
  final SupportStatusRepositoryImpl repo;
  final int serviceId;

  int statusId; // status_id actual
  String type; // begin | end | ""

  SupportStatusViewModel({
    required this.repo,
    required this.serviceId,
    required this.statusId,
    required this.type,
  });

  bool loading = false;

  final options = const [
    SupportStatusEntity(id: 24, label: 'Baño', icon: Icons.wc),
    SupportStatusEntity(id: 22, label: 'Comer', icon: Icons.restaurant),
    SupportStatusEntity(id: 38, label: 'Dormir', icon: Icons.hotel),
    SupportStatusEntity(
        id: 39, label: 'Gasolina', icon: Icons.local_gas_station),
  ];

  /// 🔹 ¿hay soporte activo?
  bool get hasActive => type == 'begin';

  /// 🔹 ¿este item está activo?
  bool isSelected(int id) => hasActive && statusId == id;

  Color cardColor(int id) {
    if (isSelected(id)) return Colors.white;
    return Colors.grey.shade200;
  }

  Color iconColor(int id) {
    if (!hasActive) return _defaultColor(id);
    if (isSelected(id)) return _defaultColor(id);
    return Colors.white;
  }

  Color _defaultColor(int id) {
    switch (id) {
      case 24:
        return Colors.blue;
      case 22:
        return Colors.orange;
      case 38:
        return Colors.black;
      case 39:
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  /// Tap handler (BEGIN / END)
  Future<void> send(int id, BuildContext context) async {
    if (loading) return;

    // hay uno activo y no es este → no permitir
    if (hasActive && statusId != id) return;

    loading = true;
    notifyListeners();

    final newType = hasActive ? 'end' : 'begin';

    final ok = await repo.sendStatus(
      serviceId: serviceId,
      statusId: id,
      type: newType,
    );

    loading = false;

    if (ok.statusCode == 200) {
      statusId = id;
      type = newType;
      notifyListeners();
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al enviar el estatus de soporte')),
      );
    }
  }
}
