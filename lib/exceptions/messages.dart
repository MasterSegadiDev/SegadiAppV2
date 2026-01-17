class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
