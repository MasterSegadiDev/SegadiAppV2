import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:segadi/models/containers/rearrangementContainer.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/models/containers/container_movements.dart';

class UbicacionesViewModel extends ChangeNotifier {
  final UbicationMovement _ubicationMovement;
  UbicacionesViewModel(this._ubicationMovement);

  List<Ubicacion> _ubicaciones = [];
  List<Ubicacion> get ubicaciones => _ubicaciones;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _token;
  String? get token => _token;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  bool _isSaving = false;
  String? _registroMensaje;
  bool get isSaving => _isSaving;
  String? get registroMensaje => _registroMensaje;

  // -------------------- NUEVAS VARIABLES --------------------
  bool isLoading = false;
  String? areaSeleccionada;
  String? espacioSeleccionado;
  String? nivelSeleccionado;

  // Reacomodo
  String? origenArea;
  String? origenEspacio;
  String? origenNivel;
  String? destinoArea;
  String? destinoEspacio;
  String? destinoNivel;

  final TextEditingController numeroSerieController = TextEditingController();
  final TextEditingController pesoBrutoController = TextEditingController();
  final TextEditingController nombreImagenPesoController =
      TextEditingController();

  String? serieAsignada;
  String? idMovimientoActual;

  String tipoMovimiento = ""; // valor por defecto

  void setTipoMovimiento(String t) {
    tipoMovimiento = t;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setRegistroMensaje(String? mensaje) {
    _registroMensaje = mensaje;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void clearForm() {
    numeroSerieController.clear();
    pesoBrutoController.clear();
    nombreImagenPesoController.clear();
    selectedImage == null;
    notifyListeners();
  }

  @override
  void dispose() {
    numeroSerieController.dispose();
    pesoBrutoController.dispose();
    nombreImagenPesoController.dispose();
    super.dispose();
  }

  PuntoMovimiento? origen;
  PuntoMovimiento? destino;

  void asignarOrigenInicial({
    String? idMovimiento,
    String? areaInicial,
    String? espacioInicial,
    String? nivelInicial,
    String? numeroSerie,
  }) {
    print('Asignando origen inicial...');
    if (areaInicial == null || espacioInicial == null || nivelInicial == null) {
      print("⚠ No se pudo asignar origen inicial, valores vacíos.");
      return;
    }

    final ubic = getUbicacion(areaInicial, espacioInicial, nivelInicial);

    if (ubic == null) {
      print("⚠ Ubicación inicial no encontrada en el mapa.");
      return;
    }

    origen = PuntoMovimiento(
      area: areaInicial,
      espacio: espacioInicial,
      nivel: nivelInicial,
      numeroSerie: ubic.numberSerie,
    );

    print("✅ Origen pre-asignado para Piso → Camión:");
    print("Origen: ${origen!.area}-${origen!.espacio} Nivel ${origen!.nivel}");
  }

  String? seleccionarPuntoReacomodo(String area, String espacio, String nivel) {
    final ubic = getUbicacion(area, espacio, nivel);
    if (ubic == null) return "Ubicación inválida.";

    final serie = (ubic.numberSerie ?? '').trim();
    final ocupado = serie.isNotEmpty;

    if (ocupado) {
      final tieneBloqueo = tieneArribaOcupados(area, espacio, nivel);
      if (tieneBloqueo) {
        return "Para mover este contenedor, primero debes mover los contenedores de arriba.";
      }

      origen = PuntoMovimiento(
        area: area,
        espacio: espacio,
        nivel: nivel,
        numeroSerie: serie,
      );

      destino = null;
      return null;
    }

    // ------------------------------------------------------------
    // Si es VACÍO → intentar asignar DESTINO, pero validando niveles
    // ------------------------------------------------------------
    if (origen == null) {
      return "Primero debes seleccionar un origen (nivel ocupado).";
    }

    // Validación: para destino nivel 2 debe existir ocupación en nivel 1,
    // para destino nivel 3 deben existir ocupaciones en nivel 1 y 2.
    final nivelDestinoInt = int.parse(nivel);

    final niveles = getNivelesPorEspacio(area, espacio)
        .where((n) => n != null && n.toString().trim().isNotEmpty)
        .map((n) => int.parse(n.toString()))
        .toList()
      ..sort();

    for (final n in niveles) {
      if (n < nivelDestinoInt) {
        final u = getUbicacion(area, espacio, n.toString());
        final vacio = u == null || (u.numberSerie ?? '').trim().isEmpty;
        if (vacio) {
          return "No puede asignar al nivel $nivelDestinoInt porque el nivel $n está vacío.";
        }
      }
    }

    // Si pasó la validación, este punto vacío se vuelve destino
    destino = PuntoMovimiento(
      area: area,
      espacio: espacio,
      nivel: nivel,
      numeroSerie: null,
    );

    return null;
  }

  bool tieneArribaOcupados(String area, String espacio, String nivel) {
    final nivelInt = int.parse(nivel);

    final niveles = getNivelesPorEspacio(area, espacio)
        .where((n) => n != null && n.trim().isNotEmpty)
        .map((n) => int.parse(n))
        .toList()
      ..sort();

    for (final n in niveles) {
      if (n > nivelInt) {
        final u = getUbicacion(area, espacio, n.toString());
        if (u != null && u.numberSerie != null && u.numberSerie!.isNotEmpty) {
          return true; // Tiene algo arriba
        }
      }
    }

    return false;
  }

  String? seleccionarPuntoCamionPiso(
      String area, String espacio, String nivel) {
    final ubic = getUbicacion(area, espacio, nivel);

    if (ubic == null) return "Ubicación inválida.";
    if (ubic.numberSerie != null && ubic.numberSerie!.isNotEmpty) {
      return "Debes seleccionar un nivel VACÍO para bajar el contenedor.";
    }

    // Guardar destino
    destino = PuntoMovimiento(
      area: area,
      espacio: espacio,
      nivel: nivel,
      numeroSerie: null, // porque es vacío
    );

    // ORIGEN viene del camión → ya está en selectedContainerNumber
    // No modificar origen.

    return null;
  }

  String? seleccionarPuntoPisoCamion(
      String area, String espacio, String nivel) {
    final ubic = getUbicacion(area, espacio, nivel);

    if (ubic == null) return "Ubicación inválida.";
    if (ubic.numberSerie == null || ubic.numberSerie!.isEmpty) {
      return "Debes seleccionar un nivel OCUPADO para enviarlo al camión.";
    }

    // Guardar origen
    origen = PuntoMovimiento(
      area: area,
      espacio: espacio,
      nivel: nivel,
      numeroSerie: ubic.numberSerie!,
    );

    // En este flujo NO hay destino
    destino = null;

    return null; // sin error
  }

  // -------------------------------------------------------
  // REACOMODO PISO → PISO
  // -------------------------------------------------------
  /// Retorna null si OK, o un mensaje de error si hay problema.
  String? _seleccionarReacomodo(
    String area,
    String espacio,
    String nivel,
    bool ocupado,
  ) {
    final ubic = getUbicacion(area, espacio, nivel);
    final ocupadoReal = ubic != null &&
        ubic.numberSerie != null &&
        ubic.numberSerie!.trim().isNotEmpty;

    // Asegura consistencia del dato
    ocupado = ocupadoReal;

    // -----------------------------------------
    // 1️⃣ No hay origen seleccionado TODAVÍA
    // -----------------------------------------
    if (origen == null) {
      if (!ocupado) {
        return "El origen debe estar ocupado.";
      }

      origen = PuntoMovimiento(
        area: area,
        espacio: espacio,
        nivel: nivel,
        numeroSerie: ubic.numberSerie,
      );

      return null;
    }

    // -----------------------------------------
    // 2️⃣ ORIGEN YA EXISTE → ¿El usuario eligió OTRO origen?
    // Si selecciona otro NIVEL OCUPADO se CAMBIA el origen.
    // -----------------------------------------
    if (ocupado && destino == null) {
      // Usuario se equivocó y quiere cambiar el origen
      origen = PuntoMovimiento(
        area: area,
        espacio: espacio,
        nivel: nivel,
        numeroSerie: ubic.numberSerie,
      );
      return null;
    }

    // -----------------------------------------
    // 3️⃣ Intento seleccionar el MISMO origen como destino
    // -----------------------------------------
    if (origen!.area == area &&
        origen!.espacio == espacio &&
        origen!.nivel == nivel) {
      return "El destino no puede ser el mismo que el origen.";
    }

    // -----------------------------------------
    // 4️⃣ Seleccionar destino
    // -----------------------------------------
    if (destino == null) {
      if (ocupado) {
        return "El destino debe ser un nivel vacío.";
      }

      destino = PuntoMovimiento(
        area: area,
        espacio: espacio,
        nivel: nivel,
      );

      return null;
    }

    return "El origen y destino ya están seleccionados.";
  }

  // -------------------------------------------------------
  // CAMIÓN → PISO
  // -------------------------------------------------------
  String? _seleccionarCamionPiso(
    String area,
    String espacio,
    String nivel,
    bool ocupado,
  ) {
    print('el nivel está ocupado? $ocupado');

    if (ocupado) {
      return "Debes seleccionar un espacio vacío para bajar el contenedor.";
    }

    destino = PuntoMovimiento(area: area, espacio: espacio, nivel: nivel);
    return null;
  }

  // -------------------------------------------------------
  // PISO → CAMIÓN
  // -------------------------------------------------------
  void _seleccionarPisoCamion(
      String area, String espacio, String nivel, bool ocupado) {
    if (origen != null) return;

    if (!ocupado) {
      throw Exception("Para enviar al camión, selecciona un nivel ocupado.");
    }

    origen = PuntoMovimiento(area: area, espacio: espacio, nivel: nivel);
  }

  // -------------------------------------------------------
  // EJECUTAR EL MOVIMIENTO
  // -------------------------------------------------------
  Future<void> ejecutarMovimiento({
    required BuildContext context,
    required String tipoMovimiento, // reacomodo | camion-piso | piso-camion
    String? serieAsignada,
    String? movementId,
    String? area,
    String? espacio,
    String? nivel,
  }) async {
    final user = UserSession();
    final siteId = user.siteId;

    print('''
          ============================
          EJECUTANDO MOVIMIENTO
          Tipo: $tipoMovimiento
          Origen: ${origen?.area}-${origen?.espacio} Nivel ${origen?.nivel}
          Destino: ${destino?.area}-${destino?.espacio} Nivel ${destino?.nivel}
          Serie Asignada: $serieAsignada
          Movimiento ID: ${movementId}
          Site ID: $siteId
          ============================
          ''');

    // ==========================================================
    // 🔎 VALIDACIÓN GENERAL
    // ==========================================================
    if (tipoMovimiento == "camion-piso") {
      if (destino == null) {
        _showMsg(context, "Selecciona un destino válido.");
        return;
      }
    } else if (tipoMovimiento == "piso-camion") {
      if (origen == null) {
        _showMsg(context,
            "No hay un origen seleccionado para realizar el movimiento Piso - Camión.");
        return;
      }
    } else {
      // reacomodo
      if (origen == null || destino == null) {
        _showMsg(context, "Selecciona origen y destino.");
        return;
      }
    }

    // ==========================================================
    // 🟦 FLUJO 1 — CAMIÓN → PISO
    // ==========================================================
    if (tipoMovimiento == "camion-piso") {
      final destinoUbic =
          getUbicacion(destino!.area, destino!.espacio, destino!.nivel);
      final serie = serieAsignada;

      if (serie == null || serie.trim().isEmpty) {
        _showMsg(context,
            "Ha ocurrido un error, el movimiento camión - piso, no contiene un numero de serie.");
        return;
      }

      try {
        await registrarMovimiento(
          movementType: "Camion-Piso",
          craneMovementId: movementId!,
          containerLocationId: destinoUbic!.id.toString(),
          numberSerie: serie,
          siteId: siteId,
        );

        // Actualiza mapa
        destinoUbic.numberSerie = serie;
        destinoUbic.color = "yellow";

        resetMovimiento();
        notifyListeners();

        _showSuccess(context, "Movimiento Camión → Piso registrado.");
      } catch (e) {
        _showError(context, "Error en Camión → Piso: $e");
      }

      return;
    }

    // ==========================================================
    // 🟩 FLUJO 2 — OBTENER ORIGEN (Reacomodo y Piso → Camión)
    // ==========================================================
    final origenUbic =
        getUbicacion(origen!.area, origen!.espacio, origen!.nivel);
    if (origenUbic == null) {
      _showMsg(context, "Error al obtener origen.");
      return;
    }

    final serie = serieAsignada;

    if (serie == null || serie.trim().isEmpty) {
      _showMsg(context, "Ha ocurrido un error al obtener el numero de serie.");
      return;
    }

    // ==========================================================
    // 🟨 FLUJO 3 — REACOMODO
    // ==========================================================
    if (tipoMovimiento == "reacomodo") {
      final destinoUbic =
          getUbicacion(destino!.area, destino!.espacio, destino!.nivel);
      if (destinoUbic == null) {
        _showMsg(context, "Error al obtener destino.");
        return;
      }

      try {
        await registrarMovimiento(
          movementType: "Reacomodo",
          contenedorActualId: origenUbic.id,
          contenedorNuevoId: destinoUbic.id,
          numberSerie: serie,
          siteId: siteId,
        );

        // Actualiza mapa
        origenUbic.numberSerie = null;
        origenUbic.color = "green";

        destinoUbic.numberSerie = serie;
        destinoUbic.color = "yellow";

        resetMovimiento();
        notifyListeners();

        _showSuccess(context, "Reacomodo completado.");
      } catch (e) {
        _showError(context, "Error en Reacomodo: $e");
      }

      return;
    }

    // ==========================================================
    // 🟥 FLUJO 4 — PISO → CAMIÓN
    // ==========================================================
    if (tipoMovimiento == "piso-camion") {
      print('ubicacion id:, ${origenUbic.id}');
      try {
        await registrarMovimiento(
          movementType: "Piso-Camion",
          craneMovementId: movementId!,
          numberSerie: serie,
          siteId: siteId,
          contenedorActualId: origenUbic.id,
        );

        // Actualiza mapa
        origenUbic.numberSerie = null;
        origenUbic.color = "green";

        resetMovimiento();
        notifyListeners();

        _showSuccess(context, "Movimiento Piso → Camión completado.");
      } catch (e) {
        _showError(context, "Error en Piso → Camión: $e");
      }

      return;
    }
  }

  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }

  void _showSuccess(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.green.shade700),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  Future<bool> confirmarMovimiento(
    BuildContext context,
    String? serie,
    PuntoMovimiento? origen,
    PuntoMovimiento? destino,
    String tipoMovimiento,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Confirmar movimiento"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Serie: $serie"),
                  const SizedBox(height: 12),

                  // ────────────────────────────────
                  // 🔵 CASO CAMIÓN → PISO
                  // ────────────────────────────────
                  if (tipoMovimiento == "camion-piso") ...[
                    const Text("Movimiento: Camión → Piso"),
                    const SizedBox(height: 8),
                    Text(
                      "Destino: ${destino?.area}-${destino?.espacio} Nivel ${destino?.nivel}",
                    ),
                  ]

                  // ────────────────────────────────
                  // 🔵 CUALQUIER OTRO MOVIMIENTO
                  // ────────────────────────────────
                  else ...[
                    Text(
                      "Origen: ${origen!.area}-${origen.espacio} Nivel ${origen.nivel}",
                    ),
                    Text(
                      "Destino: ${destino?.area}-${destino?.espacio} Nivel ${destino?.nivel}",
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Confirmar"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // -------------------------------------------------------
  void resetMovimiento() {
    origen = null;
    destino = null;
  }

  Future<void> cargarListado() async => await cargarUbicacionesDesdeApi();

  /// -------------------- CARGA DE UBICACIONES --------------------
  Future<void> cargarUbicacionesDesdeApi() async {
    final user = UserSession();
    final siteId = user.siteId;

    print('🔄 Cargando ubicaciones para SITE ID: $siteId');

    isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      'http://198.251.68.42/DesarrolloSEGADI/web/index.php'
      '?r=esegadi/getubicaciones'
      '&id=100'
      '&site_id=$siteId'
      '&token=1000',
    );

    print('🌐 URL de sitios: $url');

    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
      });

      print('📡 Código de respuesta: ${response.statusCode}');
      print('📥 Respuesta cruda: ${response.body}');

      if (response.statusCode != 200) {
        _ubicaciones = [];
        _errorMessage = 'Error al cargar ubicaciones: ${response.statusCode}';
        return;
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['ubicaciones'] is! List) {
        _ubicaciones = [];
        _errorMessage =
            'No se encontraron ubicaciones para el sitio seleccionado.';
        return;
      }

      final ubicacionesList = jsonData['ubicaciones'] as List;

      _ubicaciones = ubicacionesList
          .map((e) => Ubicacion.fromJson(e))
          .where((u) => u.id != null) // Limpieza básica
          .toList();

      _errorMessage = null;
    } catch (e, stacktrace) {
      debugPrint('❌ Error al cargar ubicaciones: $e');
      debugPrint(stacktrace.toString());

      _ubicaciones = [];
      _errorMessage = 'Error de conexión al cargar ubicaciones.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------- FILTROS --------------------
  List<String> getAreas() => _ubicaciones.map((u) => u.area).toSet().toList();
  List<String> getEspaciosPorArea(String area) => _ubicaciones
      .where((u) => u.area == area)
      .map((u) => u.espacio)
      .toSet()
      .toList();
  List<String> getNivelesPorEspacio(String area, String espacio) => _ubicaciones
      .where((u) => u.area == area && u.espacio == espacio)
      .map((u) => u.nivel)
      .toSet()
      .toList();
  List<String> getNivelesPorEspacioCamionPiso(String area, String espacio) =>
      _ubicaciones
          .where((u) => u.area == area && u.espacio == espacio)
          .map((u) => u.nivel)
          .toSet()
          .toList();
  List<Ubicacion> getUbicacionesPorAreaEspacioYNivel(
          String area, String espacio, [String? nivel]) =>
      _ubicaciones
          .where((u) =>
              u.area == area &&
              u.espacio == espacio &&
              (nivel == null || u.nivel == nivel))
          .toList();
  List<Ubicacion> getTodasUbicacionesOcupadas() => _ubicaciones
      .where((u) => u.estado.toLowerCase().trim() == 'used')
      .toList();
  Ubicacion? getUbicacion(String area, String espacio, String nivel) =>
      _ubicaciones.firstWhereOrNull(
          (u) => u.area == area && u.espacio == espacio && u.nivel == nivel);
  bool esNivelLibre(String area, String espacio, String nivel) {
    final ubicacion = getUbicacion(area, espacio, nivel);
    return ubicacion != null && ubicacion.estado.toLowerCase().trim() != 'used';
  }

  bool nivelEstaOcupado(String area, String espacio, String nivel) =>
      !esNivelLibre(area, espacio, nivel);
  bool nivelEstaOcupadoCamionPiso(String area, String espacio, String nivel) =>
      !esNivelLibre(area, espacio, nivel);
  bool esNivelLibreCamionPiso(String area, String espacio, String nivel) =>
      esNivelLibre(area, espacio, nivel);

  // -------------------- SELECCIÓN --------------------
  void setAreaSeleccionada(String area) {
    areaSeleccionada = area;
    espacioSeleccionado = null;
    nivelSeleccionado = null;
    notifyListeners();
  }

  void setSeleccion({
    required String area,
    required String espacio,
    required String nivel,
    required bool isOrigen,
    required Ubicacion ubicacion,
  }) {
    if (isOrigen) {
      origenArea = area;
      origenEspacio = espacio;
      origenNivel = nivel;
    } else {
      destinoArea = area;
      destinoEspacio = espacio;
      destinoNivel = nivel;
    }
    notifyListeners();
  }

  // -------------------- MÉTODOS DE MOVIMIENTO --------------------
  Future<bool> saveMovement(Movimiento movimiento) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Llamamos al servicio.
      // Si falla (400, 500, etc), Dio lanzará una excepción automáticamente.
      await _ubicationMovement.saveMovement(movimiento);

      notifyListeners();
      return true; // Retornamos éxito para que la vista sepa que puede cerrar el mapa
    } catch (e) {
      // 2. Aquí capturamos el mensaje de error que definimos en ApiException
      _errorMessage = e.toString();
      debugPrint('❌ Error en saveMovement: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> saveTruckFloor({
    required String id, //destino id donde se va a colocar el contendor
    required String craneMovementId, //id del movimiento de grua
    String? numberSerie, //numero de serie del contendor
    String? movementType, //tipo de movimiento
    String? siteId, //site id
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userId = prefs.getInt('id') ?? 0;

    Movimiento movimiento = Movimiento(
      crane_movement_id: int.tryParse(craneMovementId) ?? 0,
      movement_type: 'Camion-Piso',
      crane_operator_id: userId.toString(),
      container_location_id: int.parse(id),
      new_container_location_id: null,
      container_number: numberSerie,
      status: null,
      token: _token ?? '',
      weight: '',
      document_name: '',
      document: '',
      site_id: siteId ?? '',
    );

    await saveMovement(movimiento);
  }

  Future<void> registrarMovimiento({
    required String movementType,
    String? contenedorActualId,
    String? contenedorNuevoId,
    String? numberSerie,
    String? siteId,
    String? craneMovementId,
    String? containerLocationId,
    String? serie, // Para pesaje
    String? peso, // Para pesaje
    String? nameImage, // Para pesaje
    String? image, // Para pesaje
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userId = prefs.getInt('id') ?? 0;

    Movimiento movimiento;

    switch (movementType) {
      // ================================================================
      // 🟦 CAMION → PISO
      // ================================================================
      case 'Camion-Piso':
        if (craneMovementId == null || containerLocationId == null) {
          throw Exception("Faltan datos para Camion-Piso");
        }

        movimiento = Movimiento(
          crane_movement_id: int.parse(craneMovementId),
          movement_type: movementType,
          crane_operator_id: userId.toString(),
          container_location_id: int.parse(containerLocationId),
          new_container_location_id: null,
          container_number: numberSerie,
          status: null,
          token: _token ?? '',
          weight: '',
          document_name: '',
          document: '',
          site_id: siteId ?? '',
        );

        print("🚚 CAMION-PISO: ${movimiento.container_number}");
        break;

      // ================================================================
      // 🟩 PISO → CAMION
      // ================================================================
      case 'Piso-Camion':
        if (craneMovementId == null) {
          throw Exception("Falta craneMovementId para Piso-Camion.");
        }
        if (contenedorActualId == null) {
          throw Exception("Debes seleccionar área, espacio y nivel.");
        }

        movimiento = Movimiento(
          crane_movement_id: int.parse(craneMovementId),
          movement_type: movementType,
          crane_operator_id: userId.toString(),
          container_location_id: int.parse(contenedorActualId),
          new_container_location_id: null,
          container_number: numberSerie,
          status: null,
          token: _token ?? '',
          weight: '',
          document_name: '',
          document: '',
          site_id: siteId ?? '',
        );

        print("📦 PISO-CAMION registrado.");
        break;

      // ================================================================
      // 🟧 REACOMODO
      // ================================================================
      case 'Reacomodo':
        print("♻ Registrando Reacomodo...");

        if (contenedorActualId == null ||
            contenedorNuevoId == null ||
            contenedorActualId.isEmpty ||
            contenedorNuevoId.isEmpty ||
            numberSerie == null ||
            numberSerie.isEmpty) {
          throw Exception("Se requieren IDs y número de serie para reacomodo");
        }

        movimiento = Movimiento(
          crane_movement_id: null,
          movement_type: 'Reacomodo',
          crane_operator_id: userId.toString(),
          container_location_id: int.parse(contenedorActualId),
          new_container_location_id: contenedorNuevoId,
          container_number: numberSerie,
          status: null,
          token: _token ?? '',
          weight: '',
          document_name: '',
          document: '',
          site_id: siteId ?? '',
        );

        print("♻ REACOMODO listo con serie: $numberSerie");
        break;

      // ================================================================
      // 🟪 PESAJE
      // ================================================================
      case 'Pesaje':
        if (craneMovementId == null) {
          throw Exception("Pesaje requiere craneMovementId.");
        }
        if (serie == null || serie.isEmpty) {
          throw Exception("El pesaje requiere número de serie.");
        }
        if (peso == null || peso.isEmpty) {
          throw Exception("El pesaje requiere un peso.");
        }
        if (nameImage == null || image == null) {
          throw Exception("El pesaje requiere nombre e imagen.");
        }

        movimiento = Movimiento(
          crane_movement_id: int.parse(craneMovementId),
          movement_type: 'Pesaje',
          crane_operator_id: userId.toString(),
          container_location_id: null,
          new_container_location_id: null,
          status: null,
          container_number: serie,
          token: _token ?? '',
          weight: peso,
          document_name: nameImage,
          document: image,
          site_id: siteId ?? '',
        );

        print("⚖ PESAJE: Serie=$serie, Peso=$peso");
        break;

      // ================================================================
      // ❌ ERROR
      // ================================================================
      default:
        throw Exception('Tipo de movimiento desconocido: $movementType');
    }

    await saveMovement(movimiento);
  }

  Future<void> registrarMovimientoPisoCamion({
    required String destinoId,
    required String movementId,
    required String numberSerie,
    required String siteId,
  }) async {
    await registrarMovimiento(
        movementType: 'Piso-Camion',
        craneMovementId: movementId,
        contenedorActualId: destinoId,
        numberSerie: numberSerie,
        siteId: siteId);
  }

  Future<void> registrarMovimientoCamionPiso({
    required dynamic destinoId,
    required String movementId,
    required String numberSerie,
    required String siteId,
  }) async {
    print('''
          ============================
          DESTINO ID: $destinoId
          MOVIMIENTO ID: $movementId
          NUMERO DE SERIE: $numberSerie
          SITE ID: $siteId
          ============================
          ''');
    // await saveTruckFloor(
    //     id: destinoId,
    //     craneMovementId: movementId,
    //     numberSerie: numberSerie,
    //     siteId: siteId);
  }

  Future<bool> registrarReacomodo({
    required String? contenedorActualId,
    required String? contenedorNuevoId,
    String? numberSerie,
    required String? siteId,
  }) async {
    if (contenedorActualId == null ||
        contenedorNuevoId == null ||
        siteId == null ||
        numberSerie == null ||
        numberSerie.isEmpty) {
      print(
          'Parámetros inválidos: contenedorActualId=$contenedorActualId, contenedorNuevoId=$contenedorNuevoId, siteId=$siteId, numberSerie=$numberSerie');
      return false;
    } else {
      try {
        await registrarMovimiento(
            movementType: 'Reacomodo',
            contenedorActualId: contenedorActualId,
            contenedorNuevoId: contenedorNuevoId,
            numberSerie: numberSerie,
            siteId: siteId);
        return true;
      } catch (e) {
        print('Error en registrarReacomodo: $e');
        return false;
      }
    }
  }

  Future<void> registrarPesaje({
    required String? movementId,
    required String serie,
    required String peso,
    required String nameImage,
    required File image,
    required String siteId,
  }) async {
    _setSaving(true);
    _setRegistroMensaje(null);
    try {
      final imageBytes = await image.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      await registrarMovimiento(
          craneMovementId: movementId?.toString(),
          movementType: 'Pesaje',
          peso: peso,
          serie: serie,
          nameImage: nameImage,
          image: base64Image,
          siteId: siteId);
      clearSelectedImage();
      _setRegistroMensaje('✅ Registro de pesaje exitoso.');
    } catch (e) {
      debugPrint('Error al registrar pesaje: $e');
      _setRegistroMensaje('❌ Error al registrar el pesaje. Intenta de nuevo.');
    } finally {
      _setSaving(false);
    }
  }

  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final originalFile = File(pickedFile.path);
      final compressed = await compressImage(originalFile);
      if (compressed != null) {
        _selectedImage = compressed;
        notifyListeners();
      }
    }
  }

  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
    );
    return result != null ? File(result.path) : null;
  }
}
