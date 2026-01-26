import 'package:segadi/features/services_assigned/domain/entities/service_entity.dart';

sealed class ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceEntity> items;
  ServicesLoaded(this.items);
}

class ServicesEmpty extends ServicesState {}

class ServicesError extends ServicesState {
  final String message;
  ServicesError(this.message);
}
