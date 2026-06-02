import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';
import 'package:segadi/features/ubications/domain/usecases/registrar_movimiento_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PesajeViewModel extends ChangeNotifier {
  final RegistrarMovimientoUseCase registrarMovimientoUseCase;

  PesajeViewModel({
    required this.registrarMovimientoUseCase,
  });

  bool isSaving = false;
  String? mensaje;

  File? selectedImage;
  String? selectedImageBase64;

  bool inputSerie = false;

  final TextEditingController numeroSerieController = TextEditingController();
  final TextEditingController pesoBrutoController = TextEditingController();
  final TextEditingController nombreImagenPesoController =
      TextEditingController();

  void setInputSerie(bool value) {
    inputSerie = value;
    notifyListeners();
  }

  Future<bool> registrarPesaje({
    required String movementId,
    required String serie,
    required String peso,
    required String nameImage,
    required String image,
  }) async {
    try {
      isSaving = true;
      mensaje = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;

      final token = prefs.getString('token') ?? '';

      // =====================================
      // VALIDACIONES BÁSICAS
      // =====================================
      if (serie.isEmpty || peso.isEmpty || nameImage.isEmpty) {
        throw Exception("Faltan datos obligatorios para el pesaje");
      }

      // =====================================
      // MOVIMIENTO
      // =====================================
      final movimiento = MovimientoRegistro(
        crane_movement_id: null,
        movement_type: 'Pesaje',
        crane_operator_id: userId.toString(),
        container_location_id: null,
        new_container_location_id: null,
        status: null,
        container_number: serie,
        token: token,
        weight: peso,
        document_name: nameImage,
        document: image,
        site_id: prefs.getString('site_id') ?? '',
      );

      // =====================================
      // API CALL
      // =====================================
      final response = await registrarMovimientoUseCase(movimiento);

      isSaving = false;

      // 🔥 CLAVE: validar respuesta real
      if (response == null || response.success == false) {
        mensaje = "❌ Error al registrar pesaje";
        notifyListeners();
        return false;
      }

      mensaje = "✅ Pesaje registrado correctamente";
      notifyListeners();
      return true;
    } catch (e) {
      isSaving = false;
      mensaje = "❌ ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      clearSelectedImage();
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image == null) return;

      final file = File(image.path);

      final bytes = await file.readAsBytes();

      selectedImage = file;

      selectedImageBase64 = base64Encode(bytes);

      notifyListeners();
    } catch (e) {
      debugPrint(
        'Error capturando imagen: $e',
      );
    }
  }

  Future<void> clearSelectedImage() async {
    try {
      if (selectedImage != null && await selectedImage!.exists()) {
        await selectedImage!.delete();
      }
    } catch (_) {}

    selectedImage = null;
    selectedImageBase64 = null;

    notifyListeners();
  }
}
