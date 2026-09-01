import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:segadi/core/device/location/location_service.dart';
import 'package:segadi/features/georuta/domain/usecases/get_geofences_usecase.dart';
import 'package:segadi/features/georuta/presentation/state/georoute_state.dart';

class GeorouteViewModel extends StateNotifier<GeorouteState> {
  final GetGeorouteUseCase _getGeorouteUseCase;
  final LocationService _locationService;

  StreamSubscription<Position>? _locationSubscription;

  /// Distancia máxima permitida fuera de la ruta.
  ///
  /// 150 metros es un punto de partida razonable para una
  /// herramienta de orientación y evita falsos positivos
  /// por pequeñas variaciones del GPS.
  static const double _offRouteThresholdMeters = 150;

  GeorouteViewModel(
    this._getGeorouteUseCase,
    this._locationService,
  ) : super(
          GeorouteState.initial(),
        );

  Future<void> loadGeoroute(
    String serviceRequestId,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final georoute = await _getGeorouteUseCase(
        serviceRequestId,
      );

      state = state.copyWith(
        isLoading: false,
        georoute: georoute,
        clearError: true,
      );

      await startLocationTracking();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ==============================================================
  // UBICACIÓN
  // ==============================================================

  Future<void> startLocationTracking() async {
    try {
      final position = await _locationService.getCurrentPosition();

      _updatePosition(position);

      await _locationSubscription?.cancel();

      _locationSubscription = _locationService.getPositionStream().listen(
        _updatePosition,
        onError: (Object error) {
          state = state.copyWith(
            isTrackingLocation: false,
            error: error.toString(),
          );
        },
      );

      state = state.copyWith(
        isTrackingLocation: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isTrackingLocation: false,
        error: e.toString(),
      );
    }
  }

  void _updatePosition(Position position) {
    final latitude = position.latitude;
    final longitude = position.longitude;

    state = state.copyWith(
      currentLatitude: latitude,
      currentLongitude: longitude,
      isOffRoute: _isOffRoute(
        latitude,
        longitude,
      ),
    );
  }

  // ==============================================================
  // DETECCIÓN FUERA DE RUTA
  // ==============================================================

  bool _isOffRoute(
    double latitude,
    double longitude,
  ) {
    final georoute = state.georoute;

    if (georoute == null) {
      return false;
    }

    final coordinates = georoute.route.coordinates;

    if (coordinates.isEmpty) {
      return false;
    }

    // Primero revisamos los puntos de la ruta.
    //
    // Esto es barato y cubre la mayoría de los casos.
    double minimumDistance = double.infinity;

    for (final point in coordinates) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        point.latitude,
        point.longitude,
      );

      if (distance < minimumDistance) {
        minimumDistance = distance;
      }

      if (minimumDistance <= _offRouteThresholdMeters) {
        return false;
      }
    }

    return minimumDistance > _offRouteThresholdMeters;
  }

  // ==============================================================
  // DETENER TRACKING
  // ==============================================================

  Future<void> stopLocationTracking() async {
    await _locationSubscription?.cancel();

    _locationSubscription = null;

    state = state.copyWith(
      isTrackingLocation: false,
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
