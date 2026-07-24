import 'location_data.dart';

abstract class LocationService {
  Future<LocationData?> getCurrentLocation();
}
