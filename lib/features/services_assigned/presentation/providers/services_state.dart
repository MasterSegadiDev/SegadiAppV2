import '../../domain/entities/assigned_service.dart';

class ServicesState {
  final bool isLoading;

  final List<AssignedService> services;

  final String? error;

  const ServicesState({
    this.isLoading = false,
    this.services = const [],
    this.error,
  });

  ServicesState copyWith({
    bool? isLoading,
    List<AssignedService>? services,
    String? error,
  }) {
    return ServicesState(
      isLoading: isLoading ?? this.isLoading,
      services: services ?? this.services,
      error: error,
    );
  }

  factory ServicesState.initial() {
    return const ServicesState();
  }
}
