import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:segadi/core/errors/failures.dart';

class ApiHandler {
  static Future<Either<Failure, T>> handleRequest<T>({
    required Future<T> Function() request,
  }) async {
    try {
      final result = await request();

      return Right(result);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Left(NetworkFailure());
      }

      if (e.response?.statusCode == 401) {
        return const Left(UnauthorizedFailure());
      }

      return Left(
        ServerFailure(
          e.response?.data['message'] ?? 'Error del servidor',
        ),
      );
    } on FormatException {
      return const Left(ParsingFailure());
    } catch (e) {
      return const Left(
        ServerFailure('Ocurrió un error inesperado'),
      );
    }
  }
}
