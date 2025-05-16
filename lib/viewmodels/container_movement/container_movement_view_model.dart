// import 'package:flutter/material.dart';
// import 'package:segadi/models/containers/container_movement.dart';
// import 'package:segadi/services/containers/container_movement_service.dart';

// class ContainerViewModel extends ChangeNotifier {
//   final ContainerService _service = ContainerService();

//   ContainerData? _data;
//   bool _isLoading = false;
//   String? selectedArea;
//   String? selectedEspacio;

//   ContainerData? get data => _data;
//   bool get isLoading => _isLoading;

//   Future<void> fetchData() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       _data = await _service.fetchContainerData();
//     } catch (e) {
//       _data = null;
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   void selectArea(String area) {
//     selectedArea = area;
//     selectedEspacio = null;
//     notifyListeners();
//   }

//   void selectEspacio(String espacio) {
//     selectedEspacio = espacio;
//     notifyListeners();
//   }

//   List<Ubicacion> getFilteredUbicaciones() {
//     if (_data == null || selectedArea == null || selectedEspacio == null)
//       return [];
//     return _data!.ubicaciones
//         .where((u) => u.area == selectedArea && u.espacio == selectedEspacio)
//         .toList();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:segadi/models/containers/container_movement.dart';

class UbicacionesViewModel extends ChangeNotifier {
  List<Ubicacion> _ubicaciones = [];

  List<Ubicacion> get ubicaciones => _ubicaciones;

  Future<void> cargarUbicacionesDesdeApi() async {
    final url = Uri.parse(
        'http://198.251.68.42/DesarrolloSEGADI/web/index.php?r=esegadi/getubicaciones&id=100&token=1000'); // 👈 cambia esto

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final ubicacionesList = jsonData['ubicaciones'] as List<dynamic>;

        _ubicaciones =
            ubicacionesList.map((e) => Ubicacion.fromJson(e)).toList();

        notifyListeners();
      } else {
        throw Exception('Error al cargar ubicaciones: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception al cargar ubicaciones: $e');
    }
  }

  List<String> getAreas() {
    return _ubicaciones.map((u) => u.area).toSet().toList();
  }

  List<String> getEspaciosPorArea(String area) {
    return _ubicaciones
        .where((u) => u.area == area)
        .map((u) => u.espacio)
        .toSet()
        .toList();
  }

  List<String> getNivelesPorEspacio(String area, String espacio) {
    return _ubicaciones
        .where((u) => u.area == area && u.espacio == espacio)
        .map((u) => u.nivel)
        .toSet()
        .toList();
  }

  List<Ubicacion> getUbicacionesPorAreaEspacioYNivel(
      String area, String espacio, String nivel) {
    return _ubicaciones
        .where(
            (u) => u.area == area && u.espacio == espacio && u.nivel == nivel)
        .toList();
  }
}
