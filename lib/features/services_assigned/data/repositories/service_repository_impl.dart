import 'package:segadi/features/services_assigned/data/datasources/service_remote_datasource.dart';
import 'package:segadi/features/services_assigned/domain/entities/service_entity.dart';
import 'package:segadi/features/services_assigned/domain/repositories/service_repository.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;

  ServicesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ServiceEntity>> getAssignedServices() async {
    return await remoteDataSource.getAssignedServices();
  }
}
