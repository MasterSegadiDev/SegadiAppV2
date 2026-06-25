import 'package:dio/dio.dart';

import 'app_exception.dart';

class DioExceptionHandler {
  static AppException handle(
    DioException exception,
  ) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _handleStatusCode(
          exception.response?.statusCode,
        );

      default:
        return const UnknownException();
    }
  }

  static AppException _handleStatusCode(
    int? statusCode,
  ) {
    switch (statusCode) {
      case 401:
        return const UnauthorizedException();

      case 403:
        return const ForbiddenException();

      case 404:
        return const NotFoundException();

      case 500:
        return const ServerException();

      default:
        return const UnknownException();
    }
  }
}
