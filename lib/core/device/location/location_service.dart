import 'package:geolocator/geolocator.dart';

abstract class LocationService {
  Future<Position> getCurrentPosition();

  Stream<Position> getPositionStream();

  Future<bool> isLocationAvailable();
}
