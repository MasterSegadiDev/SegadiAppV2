import '../../domain/entities/checklist_checkpoint_entity.dart';

class ChecklistCheckpointDto extends ChecklistCheckpointEntity {
  const ChecklistCheckpointDto({
    required super.id,
    required super.checkpointName,
    required super.result,
  });

  factory ChecklistCheckpointDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChecklistCheckpointDto(
      id: json['strId']?.toString() ?? '',
      checkpointName: json['strCheckpointName'] ?? '',
      result: json['blnResult'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strId': id,
      'blnResult': result,
    };
  }
}
