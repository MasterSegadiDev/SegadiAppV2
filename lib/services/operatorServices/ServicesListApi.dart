import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:segadi/models/services/services.dart';
import 'package:segadi/utils/global_variables.dart';
import 'package:segadi/exceptions/messages.dart';

class ServicesApi {
  Future<List<Services>> fetchAssignedServices({int retry = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final int? id = prefs.getInt('id');
      final String? token = prefs.getString('token');

      if (id == null || id == 0) {
        throw ApiException('Usuario no válido. Vuelve a iniciar sesión.');
      }

      if (token == null || token.isEmpty) {
        throw ApiException('Sesión expirada. Inicia sesión nuevamente.');
      }

      final uri = Uri.parse('${GlobalVariables.baseUrl}index.php').replace(
        queryParameters: {
          'r': 'esegadi/getactivas',
          'id': id.toString(),
          'token': token,
        },
      );

      //print('[ServicesApi] Request URL: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      //print('[ServicesApi] Status: ${response.statusCode}');
      //print('[ServicesApi] Body: ${response.body}');

      dynamic decodedBody;
      try {
        decodedBody = json.decode(response.body);
      } catch (_) {
        decodedBody = null;
      }

      // ✅ Respuesta exitosa
      if (response.statusCode == 200) {
        if (decodedBody == null) {
          return [];
        }

        if (decodedBody is List) {
          return decodedBody.map((json) => Services.fromJson(json)).toList();
        }

        // Backend respondió algo distinto a lista
        throw ApiException(
          'Respuesta inválida del servidor. Intenta más tarde.',
        );
      }

      // ❌ Manejo por códigos HTTP
      switch (response.statusCode) {
        case 400:
          throw ApiException(
              _extractMessage(decodedBody) ?? 'Solicitud incorrecta.');
        case 401:
        case 403:
          throw ApiException('Sesión expirada. Inicia sesión nuevamente.');
        case 404:
          return []; // Recurso no encontrado = lista vacía
        case 500:
          throw ApiException('Error interno del servidor.');
        default:
          throw ApiException(
            'Error desconocido (${response.statusCode}).',
          );
      }
    } on TimeoutException catch (_) {
      if (retry > 0) {
        return fetchAssignedServices(retry: retry - 1);
      }
      throw NetworkException('Tiempo de espera agotado.');
    } on SocketException {
      if (retry > 0) {
        return fetchAssignedServices(retry: retry - 1);
      }
      throw NetworkException('Sin conexión a internet.');
    } on ApiException {
      rethrow;
    } catch (e) {
      print('[ServicesApi] Unexpected error: $e');
      throw ApiException(
        'No se pudo obtener la información. Intenta más tarde.',
      );
    }
  }

  /// Extrae el mensaje de un JSON sin romper si el backend cambia el nombre del campo
  static String _extractMessage(dynamic body,
      [String defaultMsg = "Ocurrió un error"]) {
    if (body == null) return defaultMsg;

    if (body is Map) {
      return body['message'] ??
          body['error'] ??
          body['error_message'] ??
          defaultMsg;
    }

    return defaultMsg;
  }
}
