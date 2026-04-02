import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Requiere esta lib
import 'package:path_provider/path_provider.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import 'package:segadi/features/travel_expenses/domain/entities/table_expense_entity.dart';
import 'package:segadi/features/travel_expenses/domain/entities/travel_expense_entity.dart';
import 'package:segadi/features/travel_expenses/domain/usecases/get_evidence_image_use_case.dart';
import 'package:segadi/features/travel_expenses/domain/usecases/travel_expenses_usecases.dart';

//enum TravelExpensesStatus { initial, loading, loaded, error }

enum TravelExpensesStatus { initial, loading, loaded, error }

class TravelExpensesViewModel extends ChangeNotifier {
  final GetAvailableConceptsUseCase getConceptsUseCase;
  final GetRegisteredExpensesUseCase getRegisteredUseCase;
  final InsertExpenseUseCase insertUseCase;
  final GetEvidenceImageUseCase getEvidenceUseCase;

  final DetailServiceRepositoryImpl detailRepository;

  TravelExpensesViewModel({
    required this.getConceptsUseCase,
    required this.getRegisteredUseCase,
    required this.insertUseCase,
    required this.getEvidenceUseCase,
    required this.detailRepository,
  });

  TravelExpensesStatus _status = TravelExpensesStatus.initial;
  String _errorMessage = '';
  bool _serviceWasClosedSuccessfully = false;

  TravelExpensesStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get serviceWasClosedSuccessfully => _serviceWasClosedSuccessfully;

  List<TravelExpenseEntity> availableConcepts = [];
  List<TableExpenseEntity> registeredExpenses = [];

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
    String? comments,
  }) async {
    _status = TravelExpensesStatus.loading;
    // IMPORTANTE: Reseteamos esta bandera para que no se quede pegada de un registro anterior
    _serviceWasClosedSuccessfully = false;
    notifyListeners();

    try {
      String? base64Image;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final result = await insertUseCase(
        serviceId: serviceId,
        conceptId: conceptId,
        amount: amount,
        comments: comments,
        base64Image: base64Image,
      );

      return await result.fold(
        (failure) async {
          _errorMessage = failure.message;
          _status = TravelExpensesStatus.error;
          notifyListeners();
          return false;
        },
        (success) async {
          debugPrint('✅ Gasto insertado correctamente: $success');

          // 1. Limpiamos la imagen seleccionada inmediatamente
          clearSelectedImage();
          _errorMessage = '';

          // 2. Refrescamos TODA la data (Conceptos y Registrados)
          // Esto actualizará 'availableConcepts'. Si la lista queda vacía,
          // la UI sabrá que debe disparar el cierre en el siguiente paso.
          await loadAllData(serviceId);

          // No ponemos _status = loaded aquí porque loadAllData ya lo hace al final
          return true;
        },
      );
    } catch (e) {
      debugPrint('❌ Error en saveExpense: $e');
      _errorMessage = "Error al procesar el envío";
      _status = TravelExpensesStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAllData(int serviceId) async {
    _status = TravelExpensesStatus.loading;
    _errorMessage = '';
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
          _errorMessage = failure
              .message; // Aquí llegará "El servicio no tiene viaticos..."
          hasError = true;
        },
        (data) => availableConcepts = List<TravelExpenseEntity>.from(data),
      );

      expensesResult.fold(
        (failure) {
          debugPrint("Expenses Error: ${failure.message}");
          _errorMessage ??= failure.message;
          hasError = true;
        },
        (data) => registeredExpenses = List<TableExpenseEntity>.from(data),
      );

      _status =
          hasError ? TravelExpensesStatus.error : TravelExpensesStatus.loaded;
    } catch (e) {
      debugPrint("Error en catch: ${e.toString()}");
      // Si entramos aquí, es un error de código, no del servidor
      _errorMessage = e.toString().contains("ApiException")
          ? e.toString().replaceAll("ApiException: ", "")
          : "Error de conexión o de datos";
      _status = TravelExpensesStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
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

  Future<void> verificarYFinalizarDesdeViaticos(int serviceId) async {
    try {
      _status = TravelExpensesStatus.loading;
      _serviceWasClosedSuccessfully = false;
      notifyListeners();

      debugPrint("--- 🧐 Verificando Cierre desde Viáticos ---");

      // 1. Consultamos los gastos registrados (para asegurar que tenemos la data fresca)
      final registeredResult = await getRegisteredUseCase(serviceId);

      bool shouldClose = false;

      registeredResult.fold(
        (failure) {
          debugPrint("❌ Error al verificar viáticos: ${failure.message}");
          shouldClose = false;
        },
        (expenses) {
          // 💡 LÓGICA DE ACTUALIZACIÓN:
          // Solo cerramos si la lista de conceptos disponibles está vacía.
          // Si 'availableConcepts' todavía tiene items, significa que el usuario
          // tiene más viáticos que reportar.

          if (availableConcepts.isEmpty) {
            debugPrint(
                "✅ No quedan conceptos disponibles. Se procederá al cierre.");
            shouldClose = true;
          } else {
            debugPrint(
                "⏳ Aún quedan ${availableConcepts.length} conceptos por registrar.");
            shouldClose = false;
          }
        },
      );

      // Solo si se cumplió la condición de arriba entramos al proceso de cierre
      if (shouldClose) {
        debugPrint("🎯 Condiciones cumplidas. Llamando a closeService...");

        final closeResult = await detailRepository.closeService(id: serviceId);

        closeResult.fold(
          (failure) {
            debugPrint(
                "⚠️ El servidor no pudo cerrar el viaje: ${failure.message}");
            _serviceWasClosedSuccessfully = false;
            _status = TravelExpensesStatus.loaded;
            notifyListeners();
          },
          (success) {
            debugPrint("✅ Servidor respondió éxito (Cierre Total)");
            _serviceWasClosedSuccessfully = true;
            _status = TravelExpensesStatus.loaded;
            notifyListeners();
          },
        );
      } else {
        // Si no debe cerrar, simplemente regresamos al estado cargado
        // para que el usuario pueda ver sus cambios.
        debugPrint("ℹ️ Operación finalizada sin cerrar remisión.");
        _status = TravelExpensesStatus.loaded;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("🚨 Error inesperado: $e");
      _status = TravelExpensesStatus.error;
      _errorMessage = e.toString();
      _serviceWasClosedSuccessfully = false;
      notifyListeners();
    }
  }
}
