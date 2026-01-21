// Helper for location services
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Position? _cachedPosition;
  static bool _permissionsGranted = false;

  static Future<Position?> getCurrentLocation({bool useCache = true}) async {
    if (useCache && _cachedPosition != null) {
      return _cachedPosition;
    }

    if (!_permissionsGranted) {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      _permissionsGranted = true;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _cachedPosition = position;
    return position;
  }
}
