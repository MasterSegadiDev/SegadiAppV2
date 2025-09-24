import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:segadi/models/user/UserSession.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/models/containers/container_movements.dart';

class UbicacionesViewModel extends ChangeNotifier {
  final UbicationMovement _ubicationMovement = UbicationMovement();

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

  Future<void> cargarListado() async => await cargarUbicacionesDesdeApi();

  /// -------------------- CARGA DE UBICACIONES --------------------
  Future<void> cargarUbicacionesDesdeApi() async {
    final user = UserSession();
    final siteId = user.siteId;
    print('🔄 Cargando ubicaciones para SITE ID: $siteId');

    isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      'http://198.251.68.42/SEGADI/web/index.php?r=esegadi/getubicaciones&id=100&site_id=$siteId&token=1000',
    );
    print('🌐 URL de sitios: $url');

    try {
      final response = await http.get(url);
      print('📡 Código de respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey('ubicaciones') &&
            jsonData['ubicaciones'] is List) {
          final ubicacionesList = jsonData['ubicaciones'] as List<dynamic>;
          _ubicaciones =
              ubicacionesList.map((e) => Ubicacion.fromJson(e)).toList();

          _errorMessage = null;
        } else {
          _ubicaciones = [];
          _errorMessage =
              'No se encontraron ubicaciones para el sitio seleccionado.';
        }
      } else {
        _ubicaciones = [];
        _errorMessage = 'Error al cargar ubicaciones: ${response.statusCode}';
      }
    } catch (e, stacktrace) {
      debugPrint('❌ Exception al cargar ubicaciones: $e');
      debugPrint('$stacktrace');
      _errorMessage = 'Error al cargar ubicaciones. Revisa tu conexión.';
      _ubicaciones = [];
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
  Future<void> saveMovement(Movimiento movimiento) async {
    _errorMessage = null;
    try {
      final response = await _ubicationMovement.saveMovement(movimiento);
      print('RESPUESTA ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Movimiento registrado con éxito.');
      } else {
        throw Exception('Error al guardar movimiento: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = 'No se pudo guardar el movimiento.';
      debugPrint('Excepción: $e');
    }
    notifyListeners();
  }

  Future<void> saveTruckFloor({
    required String id,
    required String craneMovementId,
    String? numberSerie,
    String? movementType,
    String? siteId,
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
    int? serviceId,
    String? status,
    String? serie,
    String? peso,
    String? nameImage,
    String? image,
    String? craneMovementId,
    String? containerLocationId,
    String? containerNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userId = prefs.getInt('id') ?? 0;

    Movimiento movimiento;

    switch (movementType) {
      case 'Camion-Piso':
        if (contenedorActualId == null) {
          throw Exception('Ubicación origen requerida para este movimiento.');
        }
        movimiento = Movimiento(
          crane_movement_id: int.parse(craneMovementId!),
          movement_type: movementType,
          crane_operator_id: userId.toString(),
          container_location_id: int.parse(containerLocationId!),
          new_container_location_id: null,
          container_number: numberSerie,
          status: null,
          token: _token ?? '',
          weight: '',
          document_name: '',
          document: '',
          site_id: siteId ?? '',
        );
        break;
      case 'Piso-Camion':
        if (contenedorActualId == null) {
          throw Exception('Ubicación origen requerida para este movimiento.');
        }
        movimiento = Movimiento(
          crane_movement_id: int.parse(craneMovementId!),
          movement_type: movementType,
          crane_operator_id: userId.toString(),
          container_location_id: int.parse(contenedorActualId),
          new_container_location_id: null,
          container_number: numberSerie,
          status: status,
          token: _token ?? '',
          weight: '',
          document_name: '',
          document: '',
          site_id: siteId ?? '',
        );
        break;
      case 'Reacomodo':
        print("📦 Registrando Reacomodo en funcion");
        // print("Número de serie: $numberSerie");
        // print("Origen: ${contenedorActualId}");
        // print("Destino: ${contenedorNuevoId}");
        // print("Site ID: $siteId");

        if (contenedorActualId == null ||
            contenedorNuevoId == null ||
            contenedorNuevoId == '' ||
            numberSerie == '') {
          print("Error al guardar el reacomodo ...");
          throw Exception('Se requieren IDs para reacomodo');
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
        print('MOVIMIENTO REACOMODO: ${movimiento.container_number}');
        break;
      case 'Pesaje':
        movimiento = Movimiento(
          crane_movement_id: null,
          movement_type: 'Pesaje',
          crane_operator_id: userId.toString(),
          container_location_id: null,
          new_container_location_id: null,
          status: null,
          container_number: serie,
          token: _token ?? '',
          weight: peso ?? '',
          document_name: nameImage ?? '',
          document: image ?? '',
          site_id: siteId ?? '',
        );
        print(
            'MOVIMIENTO Y VARIABLES ${movimiento.movement_type} ${movimiento.crane_operator_id} ${movimiento.container_number}  document name ${movimiento.document_name} imagen ${movimiento.document}');
        break;
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
    await saveTruckFloor(
        id: destinoId,
        craneMovementId: movementId,
        numberSerie: numberSerie,
        siteId: siteId);
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
