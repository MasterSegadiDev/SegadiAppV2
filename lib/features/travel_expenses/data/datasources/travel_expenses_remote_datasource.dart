import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:segadi/features/travel_expenses/data/models/table_expense_model.dart';
import 'package:segadi/features/travel_expenses/data/models/travel_expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/features/travel_expenses/core/errors/travel_expenses_failure.dart';

class TravelExpensesRemoteDataSource {
  final Dio _dio;
  TravelExpensesRemoteDataSource(this._dio);

  // 1. Obtener conceptos disponibles para agregar
  Future<List<TravelExpenseModel>> getConcepts(int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // El servidor truena porque no encuentra 'id'
      final response = await _dio.get('index.php', queryParameters: {
        'r': 'esegadi/getcomprobaciones',
        'id': prefs.getInt('id'), // <--- ASEGÚRATE QUE ESTO NO SEA NULL
        'id_remision': serviceId, // <--- O id_servicio, según pida tu API
        'token': prefs.getString('token'),
      });

      final data = response.data;

      if (data is List) {
        return data.map((json) => TravelExpenseModel.fromJson(json)).toList();
      }

      // Si el API manda el error_message que manejamos antes
      if (data is Map && data.containsKey('error_message')) {
        throw TravelExpensesFailure(message: data['error_message']);
      }

      return [];
    } on DioException catch (e) {
      // Esto atrapará el Error 500 y usará tu clase TravelExpensesFailure
      throw TravelExpensesFailure.fromDioError(e);
    }
  }

  // 2. Obtener gastos YA registrados (la tabla)
  Future<List<TableExpenseModel>> getRegisteredExpenses(int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await _dio.get('index.php', queryParameters: {
        'r': 'esegadi/getcomprobacionestabla',
        'id': prefs.getInt('id'),
        'id_remision': serviceId,
        'token': prefs.getString('token'),
      });

      final data = response.data;

      // Caso de Éxito: Es una lista
      if (data is List) {
        return data.map((e) => TableExpenseModel.fromJson(e)).toList();
      }

      // Caso de Error del Backend: Viene el Map con error_message
      if (data is Map && data.containsKey('error_message')) {
        // Lanzamos un DioException manual para que lo cachee el bloque catch
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      return [];
    } on DioException catch (e) {
      // Aquí es donde usamos TU CLASE
      throw TravelExpensesFailure.fromDioError(e);
    } catch (e) {
      throw TravelExpensesFailure(message: "Error inesperado: $e");
    }
  }

  // 3. Insertar nuevo gasto
  Future<bool> insertExpense({
    required int serviceId,
    required int conceptId,
    required double amount,
    required String comments,
    String? image,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      "service_id": serviceId,
      "token": prefs.getString('token'),
      "money_check_id": conceptId,
      "total_used": amount,
      "comments": comments,
      "document_name": "evidencia_$conceptId",
      "document": image,
    };

    final response = await _dio.post(
      'index.php',
      queryParameters: {'r': 'esegadi/comprobacionespost'},
      data: data,
    );

    return response.statusCode == 200;
  }

  // 4. Descargar imagen de evidencia
  Future<Uint8List> fetchImage(String conceptId) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Pedimos la URL de la evidencia
    final response = await _dio.get('index.php', queryParameters: {
      'r': 'esegadi/getcomprobacionevidencia',
      'id_user': prefs.getInt('id'),
      'money_check_id': conceptId,
      'token': prefs.getString('token'),
    });

    // 🚩 VALIDACIÓN CRÍTICA: Revisamos si 'evidencia' o 'url' vienen nulos
    if (response.data == null ||
        response.data['evidencia'] == null ||
        response.data['evidencia']['url'] == null ||
        response.data['evidencia']['url'].toString().isEmpty) {
      // Lanzamos una excepción personalizada que el Repository atrapará
      throw Exception("No hay evidencia registrada para este concepto");
    }

    // 2. Extraemos la URL de forma segura
    final String imageUrl = response.data['evidencia']['url'];

    // 3. Descargamos los bytes con un manejo de errores extra
    try {
      final imageRes = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          // Agregamos un tiempo de espera para que no se quede colgado en el ZTE
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (imageRes.data == null || (imageRes.data as List).isEmpty) {
        throw Exception("La imagen del servidor está vacía (0 bytes)");
      }

      return Uint8List.fromList(imageRes.data);
    } catch (e) {
      throw Exception("Error al conectar con el servidor de imágenes: $e");
    }
  }
}
