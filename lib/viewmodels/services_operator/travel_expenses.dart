// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:segadi/models/services/table_expeneses.dart';
// import 'package:segadi/models/services/travel_expenses.dart';
// import 'package:segadi/utils/global_variables.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;

// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:http/http.dart' as http;

// class TravelExpensesViewModel extends ChangeNotifier {
//   TravelExpenses _travelExpenses = TravelExpenses();
//   TableExpenses _tableExpenses = TableExpenses();

//   final TextEditingController textController = TextEditingController();
//   final TextEditingController textController1 = TextEditingController();
//   //int serviceDetailId = GlobalVariables.serviceDetailId;
//   int get serviceDetailId => GlobalVariables.serviceDetailId;

//   TextEditingController evidenceNameController = TextEditingController();
//   File? selectedImage;

//   TableExpenses? _table;
//   TableExpenses? get table => _table;

//   String _import = '';
//   String get import => _import;

//   set import(String value) {
//     _import = value;
//     notifyListeners();
//   }

//   String _comentary = '';
//   String get comentary => _comentary;

//   set comentary(String value) {
//     _comentary = value;
//     notifyListeners();
//   }

//   String _name = '';
//   String get name => _name;

//   set name(String value) {
//     _name = value;
//     notifyListeners();
//   }

//   int _conceptId = 0;
//   int get conceptId => _conceptId;

//   set conceptId(int value) {
//     _conceptId = value;
//     notifyListeners();
//   }

//   String? _errorMessage = null;
//   String? get errorMessage => _errorMessage;

//   String? _base64Image = null;
//   String? get base64Image => _base64Image;

//   List<TravelExpenses> _items = [];
//   List<TravelExpenses> get items => _items;

//   TravelExpenses? _selectedItem;
//   TravelExpenses? get selectedItem => _selectedItem;

//   List<TableExpenses> _tableItems = [];
//   List<TableExpenses> get tableItems => _tableItems;

//   final bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   bool _bandera = false;
//   bool get bandera => _bandera;

//   List<TravelExpenses> _data = [];
//   List<TravelExpenses> get data => _data;

//   TravelExpensesViewModel() {
//     //fetchItemsTravelExpenses();
//   }

//   Future<void> pickImageFromCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       File? originalFile = File(pickedFile.path);
//       File? compressed = await compressImage(originalFile);

//       if (compressed != null) {
//         selectedImage = compressed;
//         notifyListeners();
//         Uint8List _imageBytes = await compressed.readAsBytes();
//         String base64Image = base64Encode(_imageBytes);
//         print('IMAGEN A INSERTAR:' + base64Image.toString());
//       }
//     }
//   }

//   Future<File?> compressImage(File file) async {
//     final dir = await getTemporaryDirectory();
//     final targetPath = path.join(
//         dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

//     final XFile? result = await FlutterImageCompress.compressAndGetFile(
//       file.path,
//       targetPath,
//       quality: 70,
//     );

//     return result != null ? File(result.path) : null;
//   }

//   void setNewDetail(int id) async {
//     print('SET id: $id');
//     GlobalVariables.serviceDetailId = id;
//     print('Global var updated: ${GlobalVariables.serviceDetailId}');

//     await fetchItemsTravelExpenses();
//     _tableItems =
//         await _tableExpenses.getTravelExpenses(GlobalVariables.serviceDetailId);
//     notifyListeners();
//   }

//   Future<Uint8List?> fetchEvidenceImage(String conceptId) async {
//     final prefs = await SharedPreferences.getInstance();
//     var userId = prefs.getInt('id') ?? 0;
//     String? token = prefs.getString('token');

//     final response = await http
//         .get(Uri.parse('${GlobalVariables.baseUrl}index.php')
//             .replace(queryParameters: {
//           'r': 'esegadi/getcomprobacionevidencia',
//           'id_user': userId.toString(),
//           'money_check_id': conceptId,
//           'token': token,
//         }))
//         .timeout(const Duration(seconds: 30));

//     print("🧾 STATUS CONSULTA EVIDENCIA: ${response.statusCode}");

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final String imageUrl = data['evidencia']['url'];
//       print('🖼️ URL de la imagen a descargar: $imageUrl');

//       final imageResponse = await http.get(Uri.parse(Uri.encodeFull(imageUrl)));
//       print("📥 STATUS DESCARGA IMAGEN: ${imageResponse.statusCode}");

//       if (imageResponse.statusCode == 200) {
//         return imageResponse.bodyBytes;
//       } else {
//         print("❌ Error al descargar imagen");
//         return null;
//       }
//     } else {
//       print("❌ Error al consultar evidencia");
//       return null;
//     }
//   }

//   Future<void> fetchItemsTravelExpenses() async {
//     _items = [];
//     _data = [];

//     _bandera = false;

//     _items = await _travelExpenses.getData(GlobalVariables.serviceDetailId);
//     if (_items.isNotEmpty) {
//       _bandera = true;
//       _data = _items;
//       _conceptId = 0;
//       _comentary = '';
//       _import = '';
//       textController.clear();
//       textController1.clear();
//     }
//     notifyListeners();
//   }

//   void setSelectedItem(TravelExpenses? id) {
//     _selectedItem = id;
//     notifyListeners();
//   }

//   Future<void> tableFetchItems() async {
//     _tableItems =
//         await _tableExpenses.getTravelExpenses(GlobalVariables.serviceDetailId);
//     notifyListeners();
//   }

//   Future<bool> insertImport() async {
//     _errorMessage = null;

//     // ✅ Validar ID de concepto
//     if (conceptId <= 0) {
//       _errorMessage = 'Necesitas seleccionar un concepto';
//       notifyListeners();
//       return false;
//     }

//     // ✅ Validar importe
//     if (import.isEmpty) {
//       _errorMessage = 'Necesitas ingresar un importe a registrar';
//       notifyListeners();
//       return false;
//     }

//     double? parsedImport = double.tryParse(import);
//     if (parsedImport == null || parsedImport <= 0) {
//       _errorMessage = 'El importe ingresado no es válido (debe ser mayor a 0)';
//       notifyListeners();
//       return false;
//     }

//     // ✅ Validar que el concepto exista
//     final concept = _data.firstWhere(
//       (e) => e.id == conceptId,
//       orElse: () => TravelExpenses(),
//     );

//     if (concept.id == null || concept.id == 0) {
//       _errorMessage = 'El concepto seleccionado no existe';
//       notifyListeners();
//       return false;
//     }

//     final paymentTotal = double.tryParse(concept.paymentTotal.toString()) ?? 0;
//     if (parsedImport > paymentTotal) {
//       _errorMessage =
//           'El importe ingresado (\$$parsedImport) es mayor al permitido (\$$paymentTotal)';
//       notifyListeners();
//       return false;
//     }

//     try {
//       // ✅ Validar imagen
//       if (selectedImage == null) {
//         _errorMessage = 'No hay imagen seleccionada';
//         notifyListeners();
//         return false;
//       }

//       Uint8List imageBytes = await selectedImage!.readAsBytes();
//       String base64Image = base64Encode(imageBytes);

//       // ✅ Llamada al backend
//       var response = await _travelExpenses.insertImport(
//         GlobalVariables.serviceDetailId,
//         conceptId,
//         parsedImport,
//         comentary,
//         name,
//         base64Image,
//       );

//       // 🔍 Depuración
//       print('Respuesta insertImport(): $response');
//       print('Tipo de respuesta: ${response.runtimeType}');

//       // ✅ Verificar respuesta
//       if (response == true) {
//         await clearSelectedImage();
//         textController.clear();
//         textController1.clear();
//         evidenceNameController.clear();
//         return true;
//       } else {
//         // Caso: el backend devuelve algo válido pero no exactamente true
//         _tableItems = await _tableExpenses
//             .getTravelExpenses(GlobalVariables.serviceDetailId);
//       }

//       textController.clear();
//       textController1.clear();
//       evidenceNameController.clear();
//       await clearSelectedImage();
//       return true; // 🔹 marcar como éxito
//     } catch (e) {
//       _errorMessage = 'Error al procesar la imagen o enviar los datos: $e';
//       print(_errorMessage);
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> clearSelectedImage() async {
//     try {
//       if (selectedImage != null) {
//         // Verifica si existe físicamente y elimina
//         if (await selectedImage!.exists()) {
//           await selectedImage!.delete();
//           print(
//               '🗑️ Imagen eliminada de memoria física: ${selectedImage!.path}');
//         }

//         // Limpia la referencia en memoria
//         selectedImage = null;
//         notifyListeners();
//       }
//     } catch (e) {
//       print('⚠️ Error al limpiar imagen: $e');
//     }
//   }
// }
