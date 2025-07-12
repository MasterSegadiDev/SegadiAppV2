import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:segadi/models/containers/container_movement.dart';
import 'package:segadi/models/containers/container_movements.dart';

class UbicacionesViewModel extends ChangeNotifier {
  // Instancia para llamadas a la API de movimientos
  final UbicationMovement _ubicationMovement = UbicationMovement();

  // Lista interna de ubicaciones
  List<Ubicacion> _ubicaciones = [];
  List<Ubicacion> get ubicaciones => _ubicaciones;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _token;
  String? get token => _token;

  File? selectedImage;

  bool _isSaving = false;
  String? _registroMensaje;
  bool get isSaving => _isSaving;
  String? get registroMensaje => _registroMensaje;

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setRegistroMensaje(String? mensaje) {
    _registroMensaje = mensaje;
    notifyListeners();
  }

  /// Limpia la imagen seleccionada y notifica
  void clearSelectedImage() {
    selectedImage = null;
    notifyListeners();
  }

  Future<void> cargarListado() async => await cargarUbicacionesDesdeApi();

  /// Carga ubicaciones desde API
  Future<void> cargarUbicacionesDesdeApi() async {
    final url = Uri.parse(
      'http://198.251.68.42/DesarrolloSEGADI/web/index.php?r=esegadi/getubicaciones&id=100&token=1000',
    );

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
      _errorMessage = 'Error al cargar ubicaciones';
      notifyListeners();
    }
  }

  /// Obtiene las áreas únicas
  List<String> getAreas() => _ubicaciones.map((u) => u.area).toSet().toList();

  /// Obtiene espacios filtrados por área
  List<String> getEspaciosPorArea(String area) => _ubicaciones
      .where((u) => u.area == area)
      .map((u) => u.espacio)
      .toSet()
      .toList();

  // Obtiene niveles filtrados por área y espacio
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

  bool esNivelLibreCamionPiso(String area, String espacio, String nivel) {
    final ubicacion = getUbicacion(area, espacio, nivel);
    return ubicacion != null && ubicacion.estado.toLowerCase().trim() != 'used';
  }

  /// Obtiene ubicaciones filtradas por área, espacio y opcional nivel
  List<Ubicacion> getUbicacionesPorAreaEspacioYNivel(
          String area, String espacio, [String? nivel]) =>
      _ubicaciones
          .where((u) =>
              u.area == area &&
              u.espacio == espacio &&
              (nivel == null || u.nivel == nivel))
          .toList();

  /// Guarda un movimiento llamando al repositorio
  Future<void> saveMovement(Movimiento movimiento) async {
    _errorMessage = null;
    try {
      final response = await _ubicationMovement.saveMovement(movimiento);
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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userId = prefs.getInt('id') ?? 0;

    Movimiento movimiento;
    movimiento = Movimiento(
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
    );

    await saveMovement(movimiento);
  }

  /// Registra un movimiento con los datos correspondientes
  Future<void> registrarMovimiento({
    required String movementType,
    String? contenedorActualId,
    String? contenedorNuevoId,
    String? numberSerie,
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
        print(
            'CONTENEDOR ACTUAL ID O NUVEO A REGISTRAR: ${containerLocationId}');
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
        );
        break;

      case 'Reacomodo':
        if (contenedorActualId == null || contenedorNuevoId == null) {
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
        );
        break;

      case 'Pesaje':
        // if (contenedorActualId == null) {
        //   throw Exception('Ubicación requerida para pesaje.');
        // }
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
        );
        print('MOVIMIENTO DE PESAJE: ${movimiento}');
        break;

      default:
        throw Exception('Tipo de movimiento desconocido: $movementType');
    }
    print(
        'MOVIMIENTO A GUARDAR : ${movimiento.crane_movement_id} ${movimiento.container_location_id} ${movimiento.container_number}');
    await saveMovement(movimiento);
  }

  Future<void> registrarMovimientoPisoCamion({
    required String destinoId,
    required String movementId,
    required String numberSerie,
  }) async {
    print(
        'UBICACION ID  : ${destinoId}, TIPO DE MOVIMIENTO : ${movementId} NUMERO DE SERIE : ${numberSerie}');
    // Lógica de llamada a la API
    await registrarMovimiento(
        movementType: 'Piso-Camion',
        craneMovementId: movementId,
        contenedorActualId: destinoId,
        numberSerie: numberSerie);
  }

  Future<void> registrarMovimientoCamionPiso({
    required dynamic destinoId,
    required String movementId,
    required String numberSerie,
  }) async {
    print(
        'UBICACION ID  : ${destinoId}, TIPO DE MOVIMIENTO : ${movementId} NUMERO DE SERIE : ${numberSerie}');

    await saveTruckFloor(
        id: destinoId, craneMovementId: movementId, numberSerie: numberSerie);
  }

  /// Registra un reacomodo de contenedores
  Future<bool> registrarReacomodo({
    required String? contenedorActualId,
    required String? contenedorNuevoId,
    String? numberSerie,
  }) async {
    if (contenedorActualId == null || contenedorNuevoId == null) {
      print('IDs inválidos para reacomodo.');
      return false;
    }

    try {
      print(
        'ID DE ORIGEN CONTENEDOR $contenedorActualId Y ID DE DESTINO CONTENEDOR $contenedorNuevoId',
      );

      await registrarMovimiento(
        movementType: 'Reacomodo',
        contenedorActualId: contenedorActualId,
        contenedorNuevoId: contenedorNuevoId,
        numberSerie: numberSerie,
      );

      return true;
    } catch (e) {
      print('Error en registrarReacomodo: $e');
      return false;
    }
  }

  /// Registra el pesaje con imagen convertida a base64
  Future<void> registrarPesaje({
    required String serie,
    required String peso,
    required String nameImage,
    required File image,
  }) async {
    _setSaving(true);
    _setRegistroMensaje(null);
    try {
      final imageBytes = await image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      print('=== REGISTRO DE PESAJE ===');
      print('Serie: $serie');
      print('Peso: $peso Toneladas');
      print('Nombre Imagen: $nameImage');
      print('Imagen (Base64): ${base64Image.substring(0, 50)}...');

      await registrarMovimiento(
        movementType: 'Pesaje',
        peso: peso,
        serie: serie,
        nameImage: nameImage,
        image: base64Image,
      );
      await Future.delayed(const Duration(seconds: 2));

      clearSelectedImage();
      notifyListeners();
      _setRegistroMensaje('✅ Registro de pesaje exitoso.');
    } catch (e) {
      debugPrint('Error al registrar pesaje: $e');
      _setRegistroMensaje('❌ Error al registrar el pesaje. Intenta de nuevo.');
    } finally {
      _setSaving(false);
    }
  }

  /// Obtiene todas las ubicaciones que están marcadas como "used"
  List<Ubicacion> getTodasUbicacionesOcupadas() => _ubicaciones
      .where((u) => u.estado.toLowerCase().trim() == 'used')
      .toList();

  /// Obtiene la primera ubicación que coincide con area, espacio y nivel
  Ubicacion? getUbicacion(String area, String espacio, String nivel) =>
      _ubicaciones.firstWhereOrNull(
          (u) => u.area == area && u.espacio == espacio && u.nivel == nivel);

  /// Selecciona una imagen usando la cámara y la comprime antes de guardar
  Future<void> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final originalFile = File(pickedFile.path);
      final compressed = await compressImage(originalFile);

      if (compressed != null) {
        selectedImage = compressed;
        notifyListeners();

        //final imageBytes = await compressed.readAsBytes();
        //final base64Image = base64Encode(imageBytes);
      }
    }
  }

  /// Comprime una imagen y devuelve un archivo comprimido
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

  bool esNivelLibre(String area, String espacio, String nivel) {
    final ubicacion = getUbicacion(area, espacio, nivel);
    return ubicacion != null && ubicacion.estado.toLowerCase().trim() != 'used';
  }

  bool nivelEstaOcupado(String area, String espacio, String nivel) {
    final ubicacion = getUbicacion(area, espacio, nivel);
    return ubicacion != null && ubicacion.estado.toLowerCase().trim() == 'used';
  }

  bool nivelEstaOcupadoCamionPiso(String area, String espacio, String nivel) {
    final ubicacion = getUbicacion(area, espacio, nivel);
    return ubicacion != null && ubicacion.estado.toLowerCase().trim() == 'used';
  }
}
