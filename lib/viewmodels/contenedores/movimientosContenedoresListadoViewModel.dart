import 'package:flutter/foundation.dart';
import 'package:segadi/models/contenedores/movimientos_contenedor.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:segadi/services/contenedores/movimientos_service.dart';

class movimientosContenedoresListadoViewModel extends ChangeNotifier {
  final MovimientosService _service;
  movimientosContenedoresListadoViewModel(this._service);

  bool _initialized = false;
  final user = UserSession();

  Future<void> init() async {
    if (_initialized) return;

    await loadMovimientos(siteId: user.siteId);
  }

  List<ContainerMovement> _movimientos = [];
  bool isLoading = false;
  String? error;

  // filtro
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  // selección
  String? selectedMovementId;
  String? selectedMovementType;
  String? selectedContainerNumber;
  String? selectedStatus;
  String? selectedInitialArea;
  String? selectedInitialEspacio;
  String? selectedInitialNivel;
  String? selectedSiteId;

  List<ContainerMovement> get movimientos => _movimientos;

  List<ContainerMovement> get movimientosFiltrados {
    if (_searchQuery.isEmpty) return _movimientos;
    final q = _searchQuery.toLowerCase();
    return _movimientos.where((m) {
      final a = (m.containerNumberA ?? '').toLowerCase();
      final b = (m.containerNumberB ?? '').toLowerCase();
      final t = (m.movementType ?? '').toLowerCase();
      final c = (m.craneMovement ?? '').toLowerCase();
      return a.contains(q) || b.contains(q) || t.contains(q) || c.contains(q);
    }).toList();
  }

  // 🚀 Esta función SÍ está correcta y funcional
  Future<void> loadMovimientos({
    bool forceReload = false,
    required String siteId,
  }) async {
    print('🔥 loadMovimientos() INICIADO con siteId=$siteId');
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final data = await _service.fetchMovimientos(
        forceReload: forceReload,
        siteId: siteId,
      );

      _movimientos = data;
      print('LISTA DE MOVIMIENTOS: ${_movimientos}');
    } catch (e, stackTrace) {
      print('ERROR AL CARGAR LOS MOVIMIENTOS: $e');
      print(stackTrace);
      error = 'No hay movimientos asignados por el momento';
      _movimientos = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await _service.fetchMovimientos(
        forceReload: true,
        siteId: user.siteId,
      );

      _movimientos = data;
      error = null;
    } catch (e) {
      error = "No se pudo actualizar la información";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedMovement({
    required ContainerMovement m,
    required String siteId,
    required String? contenedorMover,
  }) {
    selectedMovementId = m.id.toString();
    selectedMovementType = m.movementType;
    selectedContainerNumber = contenedorMover;
    selectedStatus = m.status;

    selectedInitialArea = m.area;
    selectedInitialEspacio = m.space;
    selectedInitialNivel = m.level;
    selectedSiteId = siteId;

    notifyListeners();
  }

  void setManualMovement({required String type}) {
    selectedMovementId = "-1";
    selectedMovementType = type;
    selectedContainerNumber = null;
    selectedStatus = "manual";
    selectedInitialArea = null;
    selectedInitialEspacio = null;
    selectedInitialNivel = null;
    notifyListeners();
  }
}
