class SupportStatusStateEntity {
  final bool active;
  final String? status;
  final String? statusName;
  final DateTime? startedAt;
  const SupportStatusStateEntity({
    required this.active,
    this.status,
    this.statusName,
    this.startedAt,
  });
  SupportStatusStateEntity copyWith({
    bool? active,
    String? status,
    String? statusName,
    DateTime? startedAt,
  }) {
    return SupportStatusStateEntity(
      active: active ?? this.active,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
