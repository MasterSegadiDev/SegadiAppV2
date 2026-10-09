import 'package:segadi/features/evidence_eir/data/datasources/evidence_eir_remote_datasource.dart';
import 'package:segadi/features/evidence_eir/data/models/delivery_evidence_eir_model.dart';
import 'package:segadi/features/evidence_eir/domain/entities/delivery_evidence_eir.dart';
import 'package:segadi/features/evidence_eir/domain/repositories/evidence_eir_repository.dart';

class EvidenceEirRepositoryImpl implements EvidenceEirRepository {
  final EvidenceEirRemoteDatasource remoteDatasource;

  EvidenceEirRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<bool> sendDeliveryEvidencesEir(
    DeliveryEvidenceEir evidence,
  ) async {
    final model = DeliveryEvidenceEirModel.fromEntity(
      evidence,
    );

    return await remoteDatasource.sendDeliveryEvidencesEir(
      model,
    );
  }
}
