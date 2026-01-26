import '../../domain/entities/service_update.dart';

class ServiceUpdateModel extends ServiceUpdate {
  ServiceUpdateModel({
    required super.servicioId,
    required super.nuevoEstado,
  });

  factory ServiceUpdateModel.fromMap(Map<String, dynamic> map) {
    return ServiceUpdateModel(
      servicioId: map['servicioId'],
      nuevoEstado: map['nuevoEstado'],
    );
  }
}
