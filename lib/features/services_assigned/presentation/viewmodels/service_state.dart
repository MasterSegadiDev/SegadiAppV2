import 'package:segadi/features/services_assigned/domain/entities/service_entity.dart';

sealed class ServicesState {}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceEntity> items;
  ServicesLoaded(this.items);
}

class ServicesError extends ServicesState {
  final String message;
  ServicesError(this.message);
}

// ESTE ES EL CAMBIO CLAVE:
class ServicesEmpty extends ServicesState {
  final String message;
  ServicesEmpty(this.message);
}
