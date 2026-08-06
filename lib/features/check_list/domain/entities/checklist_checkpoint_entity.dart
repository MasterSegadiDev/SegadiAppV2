class ChecklistCheckpointEntity {
  final String id;
  final String checkpointName;
  final bool result;

  const ChecklistCheckpointEntity({
    required this.id,
    required this.checkpointName,
    required this.result,
  });

  ChecklistCheckpointEntity copyWith({
    String? id,
    String? checkpointName,
    bool? result,
  }) {
    return ChecklistCheckpointEntity(
      id: id ?? this.id,
      checkpointName: checkpointName ?? this.checkpointName,
      result: result ?? this.result,
    );
  }
}
