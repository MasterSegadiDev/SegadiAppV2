import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/georoute_model.dart';

class GeorouteState {
  final bool isLoading;
  final bool isTrackingLocation;
  final bool isOffRoute;

  final GeorouteModel? georoute;

  final double? currentLatitude;
  final double? currentLongitude;

  final String? error;

  const GeorouteState({
    required this.isLoading,
    required this.isTrackingLocation,
    required this.isOffRoute,
    required this.georoute,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.error,
  });

  factory GeorouteState.initial() {
    return const GeorouteState(
      isLoading: false,
      isTrackingLocation: false,
      isOffRoute: false,
      georoute: null,
      currentLatitude: null,
      currentLongitude: null,
      error: null,
    );
  }

  LatLng? get currentLocation {
    if (currentLatitude == null || currentLongitude == null) {
      return null;
    }

    return LatLng(
      currentLatitude!,
      currentLongitude!,
    );
  }

  GeorouteState copyWith({
    bool? isLoading,
    bool? isTrackingLocation,
    bool? isOffRoute,
    GeorouteModel? georoute,
    double? currentLatitude,
    double? currentLongitude,
    String? error,
    bool clearError = false,
  }) {
    return GeorouteState(
      isLoading: isLoading ?? this.isLoading,
      isTrackingLocation: isTrackingLocation ?? this.isTrackingLocation,
      isOffRoute: isOffRoute ?? this.isOffRoute,
      georoute: georoute ?? this.georoute,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      error: clearError ? null : error ?? this.error,
    );
  }
}
