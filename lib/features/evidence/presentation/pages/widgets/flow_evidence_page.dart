import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/features/evidence/data/datasources/evidence_remote_datasource.dart';
import 'package:segadi/features/evidence/data/repositories/evidence_repository_impl.dart';
import 'package:segadi/features/evidence/domain/repositories/evidence_repository.dart';
import 'package:segadi/features/evidence/domain/usecases/send_evidence_usecase.dart';
import 'package:segadi/features/evidence/presentation/pages/capture_evidence_page.dart';
import 'package:segadi/features/evidence/presentation/viewmodel/evidence_flow_viewmodel.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';
import 'package:segadi/services/operatorServices/DetailServiceApi.dart';

class EvidenceFlowPage extends StatelessWidget {
  final int serviceId;

  const EvidenceFlowPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EvidenceFlowViewModel(
        id: serviceId,
        repository: EvidenceRepositoryImpl(
          EvidenceRemoteDataSource(),
        ),
        detailServiceApi: DetailServiceRepositoryImpl(
          DetailServiceApi(),
        ),
      ),
      child: const CaptureEvidencePage(),
    );
  }
}
