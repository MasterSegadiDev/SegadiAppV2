import 'package:flutter/material.dart';
import 'package:segadi/features/georuta/domain/entities/geofence_entity.dart';
import 'package:segadi/features/georuta/domain/usecases/get_geofences_usecase.dart';

class GeorouteViewModel extends ChangeNotifier {
  final GetGeofencesUseCase getGeofencesUseCase;

  GeorouteViewModel({
    required this.getGeofencesUseCase,
  });

  bool isLoading = false;
  String? error;

  GeofenceEntity? geofences;

  Future<void> loadGeofences(
    String serviceRequestId,
  ) async {
    try {
      isLoading = true;
      error = null;

      notifyListeners();

      geofences = await getGeofencesUseCase(
        serviceRequestId,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
}
