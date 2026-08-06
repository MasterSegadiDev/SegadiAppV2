import '../../domain/entities/service_action_entity.dart';

class ServiceActionModel extends ServiceActionEntity {
  const ServiceActionModel({
    required super.enabled,
    required super.show,
  });

  factory ServiceActionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceActionModel(
      enabled: json['enabled'] ?? false,
      show: json['show'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'show': show,
    };
  }

  const ServiceActionModel.empty()
      : super(
          enabled: false,
          show: false,
        );
}
