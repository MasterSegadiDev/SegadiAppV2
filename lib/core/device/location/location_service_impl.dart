import 'package:geolocator/geolocator.dart';

import 'location_data.dart';
import 'location_service.dart';

class LocationServiceImpl implements LocationService {
  @override
  Future<LocationData?> getCurrentLocation() async {
    final permission = await _checkPermission();

    if (!permission) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<bool> _checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
