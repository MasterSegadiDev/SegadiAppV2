import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:segadi/core/network/dio_client.dart';
import 'package:segadi/features/trip_closure/data/datasources/document_scanner.dart';
import 'package:segadi/features/trip_closure/data/datasources/trip_closure_remote_datasource.dart';
import 'package:segadi/features/trip_closure/data/trip_closure_repository_impl.dart';
import 'package:segadi/features/trip_closure/presentation/pages/capture_trip_evidence_page.dart';
import 'package:segadi/features/trip_closure/presentation/viewmodels/trip_closure_viewmodel.dart';

class TripClosureFlowPage extends StatelessWidget {
  const TripClosureFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = DioClient().dio;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final int id = args['id'];
    final String serviceId = args['serviceId'];

    return ChangeNotifierProvider(
      create: (_) => TripClosureViewModel(
        repository: TripClosureRepositoryImpl(
          TripClosureRemoteDataSource(dio),
        ),
        scanner: MobileDocumentScanner(),
        id: id,
        serviceId: serviceId,
      ),
      child: const CaptureTripEvidencePage(),
    );
  }
}
