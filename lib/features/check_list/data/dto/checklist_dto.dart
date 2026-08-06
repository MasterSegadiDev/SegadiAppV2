import '../../domain/entities/checklist_entity.dart';

import 'checklist_checkpoint_dto.dart';

class ChecklistDto extends ChecklistEntity {
  const ChecklistDto({
    required super.id,
    required super.referralId,
    required super.serviceRequestId,
    required super.dateTime,
    required super.checkpoints,
  });

  factory ChecklistDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChecklistDto(
      id: json['_id'] ?? '',
      referralId: json['strReferralId'] ?? '',
      serviceRequestId: json['intServiceRequestId'] ?? 0,
      dateTime: DateTime.tryParse(
            json['dteDateTime'] ?? '',
          ) ??
          DateTime.now(),
      checkpoints: (json['arrCheckpoints'] as List<dynamic>? ?? [])
          .map(
            (e) => ChecklistCheckpointDto.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'strReferralId': referralId,
      'intServiceRequestId': serviceRequestId,
      'dteDateTime': dateTime.toIso8601String(),
      'arrCheckpoints': checkpoints
          .map(
            (e) => ChecklistCheckpointDto(
              id: e.id,
              checkpointName: e.checkpointName,
              result: e.result,
            ).toJson(),
          )
          .toList(),
    };
  }
}
