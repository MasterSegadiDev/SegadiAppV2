import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/core/network/network_info.dart';
import 'package:segadi/features/evidence/data/datasources/evidence_remote_datasource.dart';
import 'package:segadi/features/evidence/data/repositories/evidence_repository_impl.dart';
import 'package:segadi/features/evidence/presentation/pages/confirm_evidence_page.dart';
import 'package:segadi/features/evidence/presentation/viewmodel/evidence_flow_viewmodel.dart';
import 'package:segadi/features/service_detail/data/repositories/detail_service_repository_impl.dart';

class EvidenceFlowPage extends StatelessWidget {
  final int serviceId;

  const EvidenceFlowPage({super.key, required this.serviceId});

  @override
  @override
  Widget build(BuildContext context) {
    final dio = DioClient().dio;
    // Creamos la instancia de networkInfo que nos pide el repositorio
    final networkInfo = NetworkInfoImpl(Connectivity());

    return ChangeNotifierProvider(
      create: (_) => EvidenceFlowViewModel(
        id: serviceId,

        repository: EvidenceRepositoryImpl(
          EvidenceRemoteDataSource(dio),
        ),
        // CORRECCIÓN AQUÍ: Usamos los nombres de los parámetros 'api' y 'networkInfo'
        detailServiceApi: DetailServiceRepositoryImpl(
          networkInfo: networkInfo, // <-- Pasamos el networkInfo que faltaba
        ),
      ),
      child: const ConfirmEvidencePage(),
    );
  }
}
