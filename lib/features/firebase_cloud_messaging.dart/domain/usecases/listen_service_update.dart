import '../entities/service_update.dart';
import '../repositories/service_repository.dart';

class ListenServicioUpdates {
  final ServiceRepository repository;

  ListenServicioUpdates(this.repository);

  Stream<ServiceUpdate> call() {
    return repository.listenUpdates();
  }
}
