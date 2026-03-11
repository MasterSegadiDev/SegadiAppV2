// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:segadi/features/travel_expenses/domain/entities/table_expense_entity.dart';
// import 'package:segadi/features/travel_expenses/domain/entities/travel_expense_entity.dart';
// import 'package:segadi/features/travel_expenses/domain/usecases/travel_expenses_usecases.dart';

// import '../../../../core/errors/failures.dart';

// enum TravelExpensesStatus { initial, loading, loaded, error, success }

// class TravelExpensesViewModel extends ChangeNotifier {
//   final GetAvailableConceptsUseCase getConceptsUseCase;
//   final GetRegisteredExpensesUseCase getRegisteredUseCase;
//   final InsertExpenseUseCase insertUseCase;

//   TravelExpensesViewModel({
//     required this.getConceptsUseCase,
//     required this.getRegisteredUseCase,
//     required this.insertUseCase,
//   });

//   TravelExpensesStatus status = TravelExpensesStatus.initial;
//   List<TableExpenseEntity> registeredExpenses = [];
//   List<TravelExpenseEntity> availableConcepts = [];
//   String? errorMessage;

//   double get totalImport =>
//       registeredExpenses.fold(0, (sum, item) => sum + item.amount);

//   File? _selectedImage;
//   File? get selectedImage => _selectedImage; // Esto corrige el error de getter

//   final ImagePicker _picker = ImagePicker();

//   Future<void> loadAllData(int serviceId) async {
//     status = TravelExpensesStatus.loading;
//     notifyListeners();

//     // Cargamos ambos en paralelo para mayor velocidad
//     final results = await Future.wait([
//       getConceptsUseCase(serviceId),
//       getRegisteredUseCase(serviceId),
//     ]);

//     results[0].fold(
//       (f) => _handleError(f),
//       (concepts) => availableConcepts = concepts as List<TravelExpenseEntity>,
//     );

//     results[1].fold(
//       (f) => _handleError(f),
//       (expenses) {
//         registeredExpenses = expenses as List<TableExpenseEntity>;
//         status = TravelExpensesStatus.loaded;
//       },
//     );
//     notifyListeners();
//   }

//   Future<void> pickImage() async {
//     try {
//       final XFile? photo = await _picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 50, // Comprimimos para que el Base64 no sea gigante
//       );

//       if (photo != null) {
//         _selectedImage = File(photo.path);
//         notifyListeners();
//       }
//     } catch (e) {
//       errorMessage = "Error al abrir la cámara: $e";
//       notifyListeners();
//     }
//   }

//   Future<bool> saveExpense({
//     required int serviceId,
//     required int conceptId,
//     required double amount,
//     required String comments,
//   }) async {
//     if (_selectedImage == null) return false;

//     status = TravelExpensesStatus.loading;
//     notifyListeners();

//     try {
//       // 1. Convertir imagen a Base64
//       final bytes = await _selectedImage!.readAsBytes();
//       final String base64Image = base64Encode(bytes);

//       // 2. Llamar al UseCase
//       final result = await insertUseCase(
//         serviceId: serviceId,
//         conceptId: conceptId,
//         amount: amount,
//         comments: comments,
//         base64Image: base64Image,
//       );

//       return result.fold(
//         (failure) {
//           errorMessage = failure.message;
//           status = TravelExpensesStatus.error;
//           notifyListeners();
//           return false;
//         },
//         (success) async {
//           _selectedImage = null; // Limpiamos la foto para el siguiente registro
//           await loadAllData(serviceId); // Recargamos la lista automáticamente
//           return true;
//         },
//       );
//     } catch (e) {
//       errorMessage = "Error en la carga: $e";
//       status = TravelExpensesStatus.error;
//       notifyListeners();
//       return false;
//     }
//   }

//   void _handleError(Failure f) {
//     status = TravelExpensesStatus.error;
//     errorMessage = f.message;
//   }
// }

import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Requiere esta lib
import 'package:path_provider/path_provider.dart';
import 'package:segadi/features/travel_expenses/domain/entities/table_expense_entity.dart';
import 'package:segadi/features/travel_expenses/domain/entities/travel_expense_entity.dart';
import 'package:segadi/features/travel_expenses/domain/usecases/get_evidence_image_use_case.dart';
import 'package:segadi/features/travel_expenses/domain/usecases/travel_expenses_usecases.dart';

enum TravelExpensesStatus { initial, loading, loaded, error }

class TravelExpensesViewModel extends ChangeNotifier {
  final GetAvailableConceptsUseCase getConceptsUseCase;
  final GetRegisteredExpensesUseCase getRegisteredUseCase;
  final InsertExpenseUseCase insertUseCase;
  final GetEvidenceImageUseCase getEvidenceUseCase;

  TravelExpensesViewModel({
    required this.getConceptsUseCase,
    required this.getRegisteredUseCase,
    required this.insertUseCase,
    required this.getEvidenceUseCase,
  });

  TravelExpensesStatus status = TravelExpensesStatus.initial;
  List<TravelExpenseEntity> availableConcepts = [];
  List<TableExpenseEntity> registeredExpenses = [];
  String? errorMessage;
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  double get totalImport =>
      registeredExpenses.fold(0.0, (sum, item) => sum + item.amount);
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // Comprimir imagen para no saturar el ancho de banda del chofer
      _selectedImage = await _compressImage(File(photo.path));
      notifyListeners();
    }
  }

  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final path =
        "${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    return await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      path,
      quality: 70, // Balance perfecto entre peso y legibilidad
      minWidth: 1024,
      minHeight: 1024,
    ).then((value) => value != null ? File(value.path) : null);
  }

  Future<bool> saveExpense({
    required int serviceId,
    required int conceptId,
    required double amount,
    required String comments,
  }) async {
    // 1. Eliminamos el "if (_selectedImage == null) return false;"
    // porque ahora la imagen puede ser opcional según el concepto.

    status = TravelExpensesStatus.loading;
    notifyListeners();

    try {
      // 2. Procesar la imagen solo si existe, de lo contrario enviar null
      String? base64Image;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final result = await insertUseCase(
        serviceId: serviceId,
        conceptId: conceptId,
        amount: amount,
        comments: comments.isEmpty ? "Registro desde App" : comments,
        base64Image: base64Image, // Enviará el String o null
      );

      // 3. Imprimir el array result (usando inspección de dartz)
      // Esto imprimirá Right([datos...]) o Left(Failure)
      debugPrint('Resultado de la inserción: $result');

      return result.fold(
        (failure) {
          errorMessage = failure.message;
          status = TravelExpensesStatus.error;
          notifyListeners();
          return false;
        },
        (success) async {
          // success aquí representa el contenido del "Right" (tu array/objeto de éxito)
          debugPrint('Datos recibidos del servidor: $success');

          clearSelectedImage();
          errorMessage = null; // Limpiamos errores previos
          await loadAllData(serviceId);
          return true;
        },
      );
    } catch (e) {
      errorMessage = e.toString();
      status = TravelExpensesStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAllData(int serviceId) async {
    status = TravelExpensesStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        getConceptsUseCase(serviceId),
        getRegisteredUseCase(serviceId),
      ]);

      final conceptsResult = results[0];
      final expensesResult = results[1];

      bool hasError = false;

      conceptsResult.fold(
        (failure) {
          debugPrint("Error al cargar conceptos: ${failure.message}");
          errorMessage = failure
              .message; // Aquí llegará "El servicio no tiene viaticos..."
          hasError = true;
        },
        (data) => availableConcepts = List<TravelExpenseEntity>.from(data),
      );

      expensesResult.fold(
        (failure) {
          debugPrint("Expenses Error: ${failure.message}");
          errorMessage ??= failure.message;
          hasError = true;
        },
        (data) => registeredExpenses = List<TableExpenseEntity>.from(data),
      );

      status =
          hasError ? TravelExpensesStatus.error : TravelExpensesStatus.loaded;
    } catch (e) {
      debugPrint("Error en catch: ${e.toString()}");
      // Si entramos aquí, es un error de código, no del servidor
      errorMessage = e.toString().contains("ApiException")
          ? e.toString().replaceAll("ApiException: ", "")
          : "Error de conexión o de datos";
      status = TravelExpensesStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners(); // Esto quita el banner rojo de la vista automáticamente
    }
  }

  void clearSelectedImage() {
    if (_selectedImage != null) {
      try {
        if (_selectedImage!.existsSync()) {
          _selectedImage!.deleteSync(); // Primero borras el archivo físico
        }
      } catch (e) {
        debugPrint("Error al eliminar archivo físico: $e");
      } finally {
        _selectedImage = null; // LUEGO pones la variable en null
        notifyListeners();
      }
    }
  }

  Future<Uint8List?> viewEvidence(int? id) async {
    if (id == null) {
      print("ViewModel: ID es nulo");
      return null;
    }

    print("ViewModel: Llamando UseCase con ID $id");
    final result = await getEvidenceUseCase(id.toString());

    return result.fold(
      (failure) {
        print("ViewModel Error: ${failure.message}");
        return null;
      },
      (bytes) {
        print("ViewModel: Imagen recibida con éxito (${bytes.length} bytes)");
        return bytes;
      },
    );
  }

  Future<Uint8List?> downloadEvidence(int? imageId) async {
    if (imageId == null) return null;

    final result = await getEvidenceUseCase(imageId.toString());
    return result.fold(
      (failure) {
        // No notificamos error aquí para no interrumpir la vista principal
        return null;
      },
      (data) => data,
    );
  }
}
