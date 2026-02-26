import 'package:segadi/features/services_assigned/domain/entities/services_result.dart';

abstract class ServicesRemoteDataSource {
  Future<ServicesResult> getAssignedServices();
}
