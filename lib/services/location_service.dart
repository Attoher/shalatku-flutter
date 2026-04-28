import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

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
    const double toRad = math.pi / 180;
    const double toDeg = 180 / math.pi;

    final double phi1 = lat * toRad;
    final double phi2 = kaabaLat * toRad;
    final double deltaLng = (kaabaLng - lng) * toRad;

    final double y = math.sin(deltaLng) * math.cos(phi2);
    final double x = math.cos(phi1) * math.sin(phi2) - 
                     math.sin(phi1) * math.cos(phi2) * math.cos(deltaLng);

    double bearing = math.atan2(y, x) * toDeg;
    if (bearing < 0) bearing += 360;
    
    return bearing;
  }
}
