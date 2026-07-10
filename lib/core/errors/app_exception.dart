class AppException implements Exception {
  final String message;

  final String? errorCode;

  const AppException(
    this.message, {
    this.errorCode,
  });

  @override
  String toString() => message;
}
