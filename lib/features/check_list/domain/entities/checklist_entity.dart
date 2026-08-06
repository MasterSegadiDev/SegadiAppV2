import 'checklist_checkpoint_entity.dart';

class ChecklistEntity {
  final String id;
  final String referralId;
  final int serviceRequestId;
  final DateTime dateTime;

  final List<ChecklistCheckpointEntity> checkpoints;

  const ChecklistEntity({
    required this.id,
    required this.referralId,
    required this.serviceRequestId,
    required this.dateTime,
    required this.checkpoints,
  });

  ChecklistEntity copyWith({
    String? id,
    String? referralId,
    int? serviceRequestId,
    DateTime? dateTime,
    List<ChecklistCheckpointEntity>? checkpoints,
  }) {
    return ChecklistEntity(
      id: id ?? this.id,
      referralId: referralId ?? this.referralId,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      dateTime: dateTime ?? this.dateTime,
      checkpoints: checkpoints ?? this.checkpoints,
    );
  }
}
