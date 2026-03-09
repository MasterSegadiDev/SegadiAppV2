import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:segadi/models/services/detail_finished.dart';
import 'package:segadi/models/services/services_finished.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/service_finished_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final Dio _dio;

  ServiceRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, List<ServicesFinished>>> getFinishedServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('id') ?? 0;
      final token = prefs.getString('token') ?? '';

      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getterminadas',
          'id': id.toString(),
          'token': token,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is String
            ? List.from(jsonDecode(response.data))
            : response.data;

        final services =
            data.map((item) => ServicesFinished.fromJson(item)).toList();
        return Right(services);
      } else {
        return Left(
            ServerFailure('Error del servidor: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return Left(ServerFailure('Tiempo de espera agotado'));
      }
      return Left(ServerFailure(e.message ?? 'Error inesperado de red'));
    } catch (e) {
      return Left(ServerFailure('Error al procesar datos'));
    }
  }

  @override
  Future<Either<Failure, DetailFinished>> getServiceDetail(
      int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id') ?? 0;
      final token = prefs.getString('token') ?? '';

      final response = await _dio.get(
        'index.php',
        queryParameters: {
          'r': 'esegadi/getterminadasdetalle', // Tu endpoint de detalle
          'id': userId.toString(),
          'service_id': serviceId.toString(),
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        // Dio ya entrega un Map en response.data
        final detail = DetailFinished.fromJson(response.data);
        return Right(detail);
      } else {
        return Left(ServerFailure(
            'Error al obtener el detalle: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      // Manejo de errores específico de red
      return Left(
          ServerFailure(e.message ?? 'Error de conexión con el servidor'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al procesar el detalle'));
    }
  }
}
