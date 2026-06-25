class AppException implements Exception {
  final String message;

  const AppException(
    this.message,
  );

  @override
  String toString() {
    return message;
  }
}

class UnauthorizedException extends AppException {
  const UnauthorizedException()
      : super(
          'Sesión expirada',
        );
}

class ForbiddenException extends AppException {
  const ForbiddenException()
      : super(
          'No tienes permisos para realizar esta acción',
        );
}

class NotFoundException extends AppException {
  const NotFoundException()
      : super(
          'Recurso no encontrado',
        );
}

class ServerException extends AppException {
  const ServerException()
      : super(
          'Error interno del servidor',
        );
}

class NetworkException extends AppException {
  const NetworkException()
      : super(
          'Sin conexión a internet',
        );
}

class UnknownException extends AppException {
  const UnknownException()
      : super(
          'Ha ocurrido un error inesperado',
        );
}
