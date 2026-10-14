import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:segadi/core/network/dio_client.dart';
import '../models/travel_expense_concept_model.dart';

class TravelExpensesRemoteDataSource {
  TravelExpensesRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance;
  final Dio _dio;

  // GET confirmado por el backend.
  Future<List<TravelExpenseConceptModel>> getConcepts(String referralId) async {
    final response =
        await _dio.get('/appUser/referral/$referralId/travel-expenses');
    final body = Map<String, dynamic>.from(response.data as Map);
    if (body['success'] != true) {
      throw Exception(
          body['message'] ?? 'No fue posible consultar los viáticos.');
    }
    final result = body['Result'];
    if (result is! List)
      throw const FormatException('Result debe ser una lista.');
    return result
        .map((item) => TravelExpenseConceptModel.fromJson(
            Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> registerExpense({
    required String referralId,
    required String travelExpenseId,
    required double amount,
    required String evidencePath,
  }) async {
    if (referralId.trim().isEmpty) {
      throw ArgumentError('El ID de remisión es obligatorio.');
    }

    if (travelExpenseId.trim().isEmpty) {
      throw ArgumentError('El ID del viático es obligatorio.');
    }

    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError(
        'El importe utilizado debe ser mayor a cero.',
      );
    }

    if (evidencePath.trim().isEmpty) {
      throw ArgumentError(
        'Debes adjuntar una fotografía.',
      );
    }

    final extension = evidencePath.split('.').last.toLowerCase();

    if (!['jpg', 'jpeg', 'png'].contains(extension)) {
      throw ArgumentError(
        'La evidencia debe ser JPG, JPEG o PNG.',
      );
    }

    final file = await MultipartFile.fromFile(
      evidencePath,
      filename: 'evidencia.$extension',
      contentType: DioMediaType.parse(
        extension == 'png' ? 'image/png' : 'image/jpeg',
      ),
    );

    final formData = FormData.fromMap({
      'fileEvidence': file,
      'fltAmount': amount,
    });

    final endpoint = '/appUser/referral/'
        '${Uri.encodeComponent(referralId)}'
        '/travel-expense/'
        '${Uri.encodeComponent(travelExpenseId)}'
        '/evidence';

    final response = await _dio.post(
      endpoint,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    final data = response.data;

    debugPrint(
      'POST TRAVEL EXPENSE STATUS: ${response.statusCode}',
    );

    if (data is Map<String, dynamic>) {
      final success = data['success'];

      if (success == false) {
        throw Exception(
          data['message'] ?? 'No fue posible registrar el viático.',
        );
      }
    }
  }

  Future<Uint8List?> getEvidenceBytes(String url) async {
    if (url.trim().isEmpty) return null;
    final response = await _dio.get<List<int>>(url,
        options: Options(responseType: ResponseType.bytes));
    final bytes = response.data;
    return bytes == null ? null : Uint8List.fromList(bytes);
  }
}
