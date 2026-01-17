import 'package:http/src/response.dart';
import 'package:segadi/features/support_status/data/api/support_status_api.dart';

class SupportStatusRepositoryImpl {
  final SupportStatusApi api;

  SupportStatusRepositoryImpl(this.api);

  Future<Response> sendStatus({
    required int serviceId,
    required int statusId,
    required String type,
  }) async {
    final res = await api.sendSupportStatus(
        serviceId: serviceId, statusId: statusId, type: type);
    return res;
  }
}
