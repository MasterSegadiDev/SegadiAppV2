class AssignedService {
  final String id;
  final String serviceNumber;
  final String customer;
  final String origin;
  final String destination;
  final String serviceType;
  final String responsible;
  final String serviceStatus;
  final String tripStatus;
  final DateTime loadingDate;
  final DateTime unloadingDate;
  final List<String> stops;

  const AssignedService({
    required this.id,
    required this.serviceNumber,
    required this.customer,
    required this.origin,
    required this.destination,
    required this.serviceType,
    required this.responsible,
    required this.serviceStatus,
    required this.tripStatus,
    required this.loadingDate,
    required this.unloadingDate,
    required this.stops,
  });
}
