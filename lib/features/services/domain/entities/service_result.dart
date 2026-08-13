import 'package:segadi/features/services/domain/entities/service_entity.dart';

class ServicesResult {
  final List<ServiceEntity> items;
  final String message;

  ServicesResult({required this.items, required this.message});
}
