import 'package:segadi/features/services_assigned/data/datasources/service_remote_datasource.dart';
import 'package:segadi/features/services_assigned/data/models/service_model.dart';
import 'package:segadi/services/operatorServices/ServicesListApi.dart';

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final ServicesApi api;

  ServicesRemoteDataSourceImpl(this.api);

  @override
  Future<List<ServiceModel>> getAssignedServices() async {
    final result = await api.fetchAssignedServices();
    return result.map((e) => ServiceModel.fromJson(e.toJson())).toList();
  }
}
