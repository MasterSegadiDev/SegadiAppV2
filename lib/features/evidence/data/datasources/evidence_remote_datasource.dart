import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:segadi/core/network/api_config.dart';
import 'package:segadi/core/network/api_exceptions.dart';

class EvidenceRemoteDataSource {
  final Dio _dio;

  EvidenceRemoteDataSource(this._dio);

  Future<void> postEvidence(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        'index.php',
        queryParameters: {'r': 'esegadi/evidenciaspost'},
        data: body,
      );

      // 🚩 Senior Tip: Validamos la respuesta exitosa
      _validateResponse(response.data);
    } on DioException catch (e) {
      // 🚩 Esto garantiza que ApiException.fromDioError extraiga el JSON del 401
      throw ApiException.fromDioError(e);
    } on ApiException {
      // 🚩 Si nosotros lanzamos la excepción en _validateResponse, que siga su camino
      rethrow;
    } catch (e) {
      // Errores de casteo o lógica inesperada
      throw ApiException("Error inesperado: ${e.toString()}");
    }
  }

  /// Separa la lógica de validación del flujo principal (Clean Code)
  void _validateResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final bool success = data['success'] ?? true;
      final hasError = data.containsKey('error_message') ||
          data.containsKey('message') && data['success'] == false;

      if (!success || hasError) {
        throw ApiException(data['error_message']?.toString() ??
            data['message']?.toString() ??
            'Error al procesar la evidencia');
      }
    }
  }
}
