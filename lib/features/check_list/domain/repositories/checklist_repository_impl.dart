import 'package:segadi/features/check_list/data/datasources/checklist_remote_dataosurce.dart';
import 'package:segadi/features/check_list/data/dto/checklist_dto.dart';
import 'package:segadi/features/check_list/data/models/checklist_checkpoint_dto.dart';

import '../../domain/entities/checklist_entity.dart';
import '../../domain/repositories/checklist_repository.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final ChecklistRemoteDatasource remoteDatasource;

  ChecklistRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<ChecklistEntity> getChecklist(
    String referralId,
  ) async {
    return await remoteDatasource.getChecklist(
      referralId,
    );
  }

  @override
  Future<bool> sendChecklist(
    ChecklistEntity checklist,
  ) async {
    final dto = ChecklistDto(
      id: checklist.id,
      referralId: checklist.referralId,
      serviceRequestId: checklist.serviceRequestId,
      dateTime: checklist.dateTime,
      checkpoints: checklist.checkpoints
          .map(
            (e) => ChecklistCheckpointDto(
              id: e.id,
              checkpointName: e.checkpointName,
              result: e.result,
            ),
          )
          .toList(),
    );

    return await remoteDatasource.sendChecklist(
      dto,
    );
  }
}
