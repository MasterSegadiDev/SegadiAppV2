import 'package:segadi/features/services_assigned/domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    super.service,
    super.client,
    super.origin,
    super.destination,
    super.scaleOne,
    super.scaleTwo,
    super.loadDate,
    super.unloadDate,
    super.status,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      service: json['service'],
      client: json['client'],
      origin: json['origin'],
      destination: json['destination'],
      scaleOne: json['stopover_1'],
      scaleTwo: json['stopover_2'],
      loadDate: json['load_date'],
      unloadDate: json['unload_date'],
      status: json['status'],
    );
  }
  ServiceEntity toEntity() {
    return ServiceEntity(
      id: id,
      service: service,
      client: client,
      origin: origin,
      destination: destination,
      scaleOne: scaleOne,
      scaleTwo: scaleTwo,
      loadDate: loadDate,
      unloadDate: unloadDate,
      status: status,
    );
  }
}
