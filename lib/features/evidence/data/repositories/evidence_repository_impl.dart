import 'package:segadi/features/evidence/data/datasources/evidence_remote_datasource.dart';
import 'package:segadi/features/evidence/data/models/delivery_confirmation_model.dart';
import 'package:segadi/features/evidence/data/models/delivery_evidence_model.dart';
import 'package:segadi/features/evidence/domain/entities/delivery_confirmation.dart';
import 'package:segadi/features/evidence/domain/entities/delivery_evidence.dart';
import 'package:segadi/features/evidence/domain/repositories/evidence_repository.dart';

class EvidenceRepositoryImpl implements EvidenceRepository {
  final EvidenceRemoteDatasource remoteDatasource;

  EvidenceRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<bool> sendDeliveryConfirmation(
    DeliveryConfirmation confirmation,
  ) async {
    final model = DeliveryConfirmationModel.fromEntity(
      confirmation,
    );

    return await remoteDatasource.sendDeliveryConfirmation(
      model,
    );
  }

  @override
  Future<bool> sendDeliveryEvidences(
    DeliveryEvidence evidence,
  ) async {
    final model = DeliveryEvidenceModel.fromEntity(
      evidence,
    );

    return await remoteDatasource.sendDeliveryEvidences(
      model,
    );
  }
}
