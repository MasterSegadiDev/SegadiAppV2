import 'package:segadi/features/firebase_cloud_messaging.dart/domain/entities/service_update.dart';
import 'package:segadi/features/firebase_cloud_messaging.dart/domain/repositories/service_repository.dart';

import '../datasources/fcm_datasource.dart';

class ServicioRepositoryImpl implements ServiceRepository {
  final FcmDatasource datasource;

  ServicioRepositoryImpl(this.datasource);

  @override
  Stream<ServiceUpdate> listenUpdates() {
    return datasource.stream;
  }
}
