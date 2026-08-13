class SupportStatusEntity {
  final String id;
  final bool enabled;
  final int sequence;
  final String category;
  final String monitoringStatus;
  final String statusType;

  const SupportStatusEntity({
    required this.id,
    required this.enabled,
    required this.sequence,
    required this.category,
    required this.monitoringStatus,
    required this.statusType,
  });
}
