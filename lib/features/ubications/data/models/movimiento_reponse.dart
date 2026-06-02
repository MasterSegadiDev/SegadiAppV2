class MovimientoResponse {
  final bool success;
  final String status;

  MovimientoResponse({
    required this.success,
    required this.status,
  });

  factory MovimientoResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final status = json['status']?.toString() ?? '';

    return MovimientoResponse(
      success: status.toLowerCase() == 'success',
      status: status,
    );
  }
}
