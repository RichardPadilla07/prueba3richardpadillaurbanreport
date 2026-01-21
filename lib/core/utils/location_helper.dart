// Helper for location services
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Position? _cachedPosition;

  static Future<Position?> getCurrentLocation({bool useCache = true}) async {
    if (useCache && _cachedPosition != null) {
      return _cachedPosition;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition();
    _cachedPosition = position;
    return position;
  }
}
