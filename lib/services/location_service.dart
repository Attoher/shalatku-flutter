import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Calculate Qibla direction in degrees from North (clockwise)
  double calculateQiblaDirection(double lat, double lng) {
    const double kaabaLat = 21.3891;
    const double kaabaLng = 39.8579;
    const double toRad = 3.141592653589793 / 180;
    const double toDeg = 180 / 3.141592653589793;

    final double dLng = (kaabaLng - lng) * toRad;
    final double latRad = lat * toRad;
    final double kaabaLatRad = kaabaLat * toRad;

    // Proper Qibla calculation
    final double sinDLng = _sin(dLng);
    final double cosLat = _cos(latRad);
    final double sinKaabaLat = _sin(kaabaLatRad);
    final double sinLat = _sin(latRad);
    final double cosKaabaLat = _cos(kaabaLatRad);
    final double cosDLng = _cos(dLng);

    final double numerator = sinDLng * cosKaabaLat;
    final double denominator = cosLat * sinKaabaLat - sinLat * cosKaabaLat * cosDLng;

    double qibla = _atan2(numerator, denominator) * toDeg;
    if (qibla < 0) qibla += 360;
    return qibla;
  }

  double _sin(double x) => _mathSin(x);
  double _cos(double x) => _mathCos(x);
  double _atan2(double y, double x) => _mathAtan2(y, x);

  double _mathSin(double x) {
    // Using dart:math
    return x - x * x * x / 6 + x * x * x * x * x / 120;
  }

  double _mathCos(double x) {
    return 1 - x * x / 2 + x * x * x * x / 24;
  }

  double _mathAtan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }

  double _atan(double x) {
    return x - x * x * x / 3 + x * x * x * x * x / 5;
  }
}
