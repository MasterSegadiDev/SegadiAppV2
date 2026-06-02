import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:segadi/features/ubications/data/models/movimiento_reponse.dart';
import 'package:segadi/features/ubications/domain/entities/movimiento_registro.dart';

class RegistroMovimientoRemoteDataSource {
  final Dio _dio;

  RegistroMovimientoRemoteDataSource(
    this._dio,
  );

  Future<MovimientoResponse> enviar(
    MovimientoRegistro movimiento,
  ) async {
    try {
      final response = await _dio.post(
        'index.php',
        queryParameters: {
          'r': 'esegadi/movimientosgruapost',
        },
        data: movimiento.toJson(),
      );

      /*
      =========================================
      STATUS CODE
      =========================================
      */

      debugPrint('ESTATUS DE LA RESPUESTA ::: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Error del servidor',
        );
      }

      /*
      =========================================
      BODY NULL
      =========================================
      */

      if (response.data == null) {
        throw Exception(
          'Respuesta vacía',
        );
      }

      /*
      =========================================
      RESPONSE
      =========================================
      */

      final result = MovimientoResponse.fromJson(
        Map<String, dynamic>.from(
          response.data,
        ),
      );

      /*
      =========================================
      VALIDAR STATUS
      =========================================
      */

      if (!result.success) {
        throw Exception(
          'No fue posible registrar el movimiento',
        );
      }

      return result;
    }

    /*
    =========================================
    DIO ERROR
    =========================================
    */

    on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Tiempo de espera agotado',
        );
      }

      if (e.response != null) {
        throw Exception(
          'Error del servidor (${e.response?.statusCode})',
        );
      }

      throw Exception(
        'Error de conexión',
      );
    }

    /*
    =========================================
    GENERAL ERROR
    =========================================
    */

    catch (e) {
      throw Exception(
        e.toString(),
      );
    }
  }
}
