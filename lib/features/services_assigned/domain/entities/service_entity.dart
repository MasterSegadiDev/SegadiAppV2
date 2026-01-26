class ServiceEntity {
  final int id;
  final String? service;
  final String? client;
  final String? origin;
  final String? destination;

  // NUEVOS CAMPOS
  final String? scaleOne;
  final String? scaleTwo;
  final String? loadDate;
  final String? unloadDate;
  final String? status;

  const ServiceEntity({
    required this.id,
    this.service,
    this.client,
    this.origin,
    this.destination,
    this.scaleOne,
    this.scaleTwo,
    this.loadDate,
    this.unloadDate,
    this.status,
  });
}
