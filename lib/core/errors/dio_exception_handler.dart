import 'package:dio/dio.dart';
import 'package:segadi/core/errors/error_messages.dart';

import 'app_exception.dart';

class DioExceptionHandler {
  DioExceptionHandler._();

  static AppException handle(
    DioException exception,
  ) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return const AppException(
          ErrorMessages.connectionTimeout,
        );

      case DioExceptionType.sendTimeout:
        return const AppException(
          ErrorMessages.sendTimeout,
        );

      case DioExceptionType.receiveTimeout:
        return AppException(
          ErrorMessages.receiveTimeout,
        );

      case DioExceptionType.connectionError:
        return const AppException(
          ErrorMessages.noInternet,
        );

      case DioExceptionType.cancel:
        return const AppException(
          ErrorMessages.requestCancelled,
        );

      case DioExceptionType.badCertificate:
        return const AppException(
          ErrorMessages.badCertificate,
        );

      case DioExceptionType.badResponse:
        return _handleResponse(
          exception.response,
        );

      case DioExceptionType.unknown:
        return const AppException(
          ErrorMessages.unknown,
        );
      case DioExceptionType.transformTimeout:
        throw UnimplementedError();
    }
  }

  static AppException _handleResponse(
    Response? response,
  ) {
    if (response == null) {
      return const AppException(
        ErrorMessages.unknown,
      );
    }

    final data = response.data;

    // Prioridad al mensaje enviado por el backend
    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return AppException(
          message,
        );
      }
    }

    switch (response.statusCode) {
      case 400:
        return const AppException(
          ErrorMessages.badRequest,
        );

      case 401:
        return const AppException(
          ErrorMessages.unauthorized,
        );

      case 403:
        return const AppException(
          ErrorMessages.forbidden,
        );

      case 404:
        return const AppException(
          ErrorMessages.notFound,
        );

      case 409:
        return const AppException(
          ErrorMessages.conflict,
        );

      case 422:
        return const AppException(
          ErrorMessages.unprocessable,
        );

      case 429:
        return const AppException(
          ErrorMessages.tooManyRequests,
        );

      case 500:
        return const AppException(
          ErrorMessages.internalServerError,
        );

      case 502:
        return const AppException(
          ErrorMessages.badGateway,
        );

      case 503:
        return const AppException(
          ErrorMessages.serviceUnavailable,
        );

      case 504:
        return const AppException(
          ErrorMessages.gatewayTimeout,
        );

      default:
        return const AppException(
          ErrorMessages.unknown,
        );
    }
  }
}
