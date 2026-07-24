class AssignedServiceDto {
  final String id;
  final String customer;
  final String origin;
  final String destination;
  final String serviceNumber;
  final String serviceType;
  final String responsible;
  final String serviceStatus;
  final String tripStatus;
  final DateTime loadingDate;
  final DateTime unloadingDate;
  final List<String> stops;

  const AssignedServiceDto({
    required this.id,
    required this.customer,
    required this.origin,
    required this.destination,
    required this.serviceNumber,
    required this.serviceType,
    required this.responsible,
    required this.serviceStatus,
    required this.tripStatus,
    required this.loadingDate,
    required this.unloadingDate,
    required this.stops,
  });

  factory AssignedServiceDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssignedServiceDto(
      id: json['id'] ?? '',
      customer: json['cliente_asignado'] ?? '',
      origin: json['origen'] ?? '',
      destination: json['destino'] ?? '',
      serviceNumber: json['numero_servicio_remision'] ?? '',
      serviceType: json['tipo_servicio'] ?? '',
      responsible: json['responsable'] ?? '',
      serviceStatus: json['estatus_remision'] ?? '',
      tripStatus: json['estatus_viaje'] ?? '',
      loadingDate: _parseDate(json['fecha_carga']),
      unloadingDate: _parseDate(json['fecha_descarga']),
      stops: (json['escalas'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    if (value.toString().trim().isEmpty) {
      return DateTime.now();
    }

    return DateTime.parse(value.toString());
  }
}
