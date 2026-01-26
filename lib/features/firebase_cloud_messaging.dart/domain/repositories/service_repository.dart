import '../entities/service_update.dart';

abstract class ServiceRepository {
  Stream<ServiceUpdate> listenUpdates();
}
