import '../../../domain/entities/assigned_service.dart';

class ServicesState {
  final bool isLoading;
  final List<AssignedService> services;
  final String? error;

  final List<AssignedService> filteredServices;
  final String searchQuery;

  const ServicesState({
    this.isLoading = false,
    this.services = const [],
    this.filteredServices = const [],
    this.searchQuery = '',
    this.error,
  });

  ServicesState copyWith({
    bool? isLoading,
    List<AssignedService>? services,
    List<AssignedService>? filteredServices,
    String? searchQuery,
    String? error,
  }) {
    return ServicesState(
      isLoading: isLoading ?? this.isLoading,
      services: services ?? this.services,
      filteredServices: filteredServices ?? this.filteredServices,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }

  factory ServicesState.initial() {
    return const ServicesState();
  }
}
