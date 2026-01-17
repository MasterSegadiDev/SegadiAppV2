import 'package:segadi/core/network/api_result.dart';
import 'package:segadi/features/service_detail/data/mappers/detail_service_mapper.dart';
import 'package:segadi/features/service_detail/domain/entities/detail_service_entity.dart';
import 'package:segadi/services/operatorServices/DetailServiceApi.dart';

class DetailServiceRepositoryImpl {
  final DetailServiceApi api;

  DetailServiceRepositoryImpl(this.api);

  Future<DetailServiceEntity> getDetail(int id) async {
    final raw = await api.fetchDetailRaw(id);
    final DetailServiceEntity entity = DetailServiceMapper.fromJson(raw);

    print('--- DetailServiceEntity ---    ${entity.id}');
    return entity;
  }

  Future<ApiResult> changeStatus({
    required int serviceId,
    required int statusId,
  }) async {
    return api.changeStatus(
      serviceId: serviceId,
      statusId: statusId,
    );
  }
}
