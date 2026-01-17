class ApiResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  ApiResult({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResult.success(Map<String, dynamic> data) {
    return ApiResult(
      success: true,
      data: data,
    );
  }

  factory ApiResult.failure(String message) {
    return ApiResult(
      success: false,
      message: message,
    );
  }
}
