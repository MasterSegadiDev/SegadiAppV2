import 'package:dio/dio.dart';
import 'package:segadi/core/errors/error_messages.dart';

import 'app_exception.dart';
import '../network/api_error.dart';

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

  static AppException _handleResponse(Response? response) {
    if (response == null) {
      return const AppException(
        ErrorMessages.unknown,
      );
    }

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final apiError = ApiError.fromJson(data);

      return AppException(
        apiError.message,
        errorCode: apiError.errorCode,
      );
    }

    switch (response.statusCode) {
      case 400:
        return const AppException(
          ErrorMessages.badRequest,
        );

      case 401:
        return const AppException(
          ErrorMessages.unauthorized,
          errorCode: 'UNAUTHORIZED',
        );

      case 403:
        return const AppException(
          ErrorMessages.forbidden,
          errorCode: 'FORBIDDEN',
        );

      case 404:
        return const AppException(
          ErrorMessages.notFound,
          errorCode: 'NOT_FOUND',
        );

      case 409:
        return const AppException(
          ErrorMessages.conflict,
          errorCode: 'CONFLICT',
        );

      case 422:
        return const AppException(
          ErrorMessages.unprocessable,
          errorCode: 'UNPROCESSABLE_ENTITY',
        );

      case 500:
        return const AppException(
          ErrorMessages.internalServerError,
          errorCode: 'INTERNAL_SERVER_ERROR',
        );

      case 503:
        return const AppException(
          ErrorMessages.serviceUnavailable,
          errorCode: 'SERVICE_UNAVAILABLE',
        );

      default:
        return const AppException(
          ErrorMessages.unknown,
        );
    }
  }
}
