import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:segadi/features/travel_expenses/data/models/table_expense_model.dart';
import 'package:segadi/features/travel_expenses/data/models/travel_expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelExpensesRemoteDataSource {
  final Dio _dio;
  TravelExpensesRemoteDataSource(this._dio);

  // 1. Obtener conceptos disponibles para agregar
  Future<List<TravelExpenseModel>> getConcepts(int serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await _dio.get('index.php', queryParameters: {
      'r': 'esegadi/getcomprobaciones',
      'id': prefs.getInt('id'),
      'id_remision': serviceId,
      'token': prefs.getString('token'),
    });
    return (response.data as List)
        .map((e) => TravelExpenseModel.fromJson(e))
        .toList();
  }

  // 2. Obtener gastos YA registrados (la tabla)
  Future<List<TableExpenseModel>> getRegisteredExpenses(int serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final response = await _dio.get('index.php', queryParameters: {
      'r': 'esegadi/getcomprobacionestabla',
      'id': prefs.getInt('id'),
      'id_remision': serviceId,
      'token': prefs.getString('token'),
    });
    return (response.data as List)
        .map((e) => TableExpenseModel.fromJson(e))
        .toList();
  }

  // 3. Insertar nuevo gasto
  Future<bool> insertExpense({
    required int serviceId,
    required int conceptId,
    required double amount,
    required String comments,
    required String image,
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
    final response = await _dio.get('index.php', queryParameters: {
      'r': 'esegadi/getcomprobacionevidencia',
      'id_user': prefs.getInt('id'),
      'money_check_id': conceptId,
      'token': prefs.getString('token'),
    });

    final String imageUrl = response.data['evidencia']['url'];
    final imageRes = await _dio.get(imageUrl,
        options: Options(responseType: ResponseType.bytes));
    return Uint8List.fromList(imageRes.data);
  }
}
