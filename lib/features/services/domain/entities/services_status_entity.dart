class ServiceStatusEntity {
  final String statusId;

  final String mandatoryStatusId;

  final String nextMandatoryStatusId;

  const ServiceStatusEntity({
    required this.statusId,
    required this.mandatoryStatusId,
    required this.nextMandatoryStatusId,
  });
}
