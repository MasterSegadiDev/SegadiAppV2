class ChecklistItemEntity {
  final int id;
  final String option;
  final int sequence;
  bool checked;

  ChecklistItemEntity({
    required this.id,
    required this.option,
    required this.sequence,
    this.checked = false,
  });
}
