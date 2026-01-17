import 'package:flutter/material.dart';
import 'package:segadi/models/containers/container_movement_list.dart';
import 'package:segadi/services/containers/container_movement_list_service.dart';
import 'package:segadi/viewmodels/container_movement/container_movement_view_model.dart';

class ContainerMovementListViewModel extends ChangeNotifier {
  final MovimientoService _service = MovimientoService();
  List<ContainerMovement> movimientos = [];
  bool isLoading = false;
  String? error;

  String? selectedMovementId;
  String? selectedMovementType;
  String? selectedContainerNumber;
  String? selectedStatus;

  String? selectedInitialArea;
  String? selectedInitialEspacio;
  String? selectedInitialNivel;

  String? selectedSiteId;

  void setSelectedMovement(
    ContainerMovement m,
    String siteId,
    String? contenedorMover,
    UbicacionesViewModel? ubicacionesVm,
  ) {
    print("---- setSelectedMovement ----");
    print("movementType recibido: '${m.movementType}'");
    print("ubicacionesVm es null? ${ubicacionesVm == null}");

    selectedMovementId = m.id.toString();
    selectedMovementType = m.movementType;
    selectedContainerNumber = contenedorMover;
    selectedStatus = m.status;

    selectedInitialArea = m.area;
    selectedInitialEspacio = m.space;
    selectedInitialNivel = m.level;

    print("Valores iniciales:");
    print(
        "area=$selectedInitialArea  espacio=$selectedInitialEspacio  nivel=$selectedInitialNivel");

    selectedSiteId = siteId;

    if ((m.movementType ?? '').trim().toLowerCase() == "piso-camion") {
      print(">> Entraste al IF Piso-Camion");

      ubicacionesVm?.asignarOrigenInicial(
        idMovimiento: selectedMovementId!,
        areaInicial: selectedInitialArea!,
        espacioInicial: selectedInitialEspacio!,
        nivelInicial: selectedInitialNivel!,
        numeroSerie: contenedorMover,
      );

      print(">>> Después de asignar origen:");
      print("origen.area = ${ubicacionesVm?.origen?.area}");
      print("origen.espacio = ${ubicacionesVm?.origen?.espacio}");
      print("origen.nivel = ${ubicacionesVm?.origen?.nivel}");
    } else {
      print("NO se cumple el IF, movementType no es Piso-Camion");
    }

    notifyListeners();
  }

  void setManualMovement({
    required String type,
  }) {
    selectedMovementId = "-1"; // No viene de la API
    selectedMovementType = type;
    selectedContainerNumber = null;
    selectedStatus = "manual";

    selectedInitialArea = null;
    selectedInitialEspacio = null;
    selectedInitialNivel = null;

    notifyListeners();
  }

  Future<void> loadMovimientos({
    bool forceReload = false,
    required String siteId,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final data = await _service.fetchMovimientos(
        forceReload: forceReload,
        siteId: siteId,
      );

      print("Movimientos recibidos: ${data.length}");

      movimientos = data;
    } catch (e, stackTrace) {
      print('ERROR AL CARGAR LOS MOVIMIENTOS: $e');
      print(stackTrace);
      error = 'No hay movimientos asignados por el momento';
      movimientos = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
