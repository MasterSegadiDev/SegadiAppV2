class ServerException implements Exception {
  final String message;
  final int? statusCode;

  // Usamos campos no nulos obligatorios para el mensaje
  ServerException({required this.message, this.statusCode});
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException({this.message = "Sesión expirada"});
}
