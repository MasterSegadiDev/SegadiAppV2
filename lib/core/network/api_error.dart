class ApiError {
  final bool success;

  final String message;

  final String errorCode;

  const ApiError({
    required this.success,
    required this.message,
    required this.errorCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Error desconocido',
      errorCode: json['error_code'] ?? 'UNKNOWN_ERROR',
    );
  }
}
