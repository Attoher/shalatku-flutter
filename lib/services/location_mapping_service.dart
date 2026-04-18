import 'dart:math';

/// Maps latitude/longitude to closest Indonesian city for prayer time lookup
class LocationMappingService {
  static const Map<String, CityCoordinates> majorCities = {
    // Java
    'Jakarta': CityCoordinates(lat: -6.2088, lng: 106.8456, province: 'DKI Jakarta', city: 'Jakarta Pusat'),
    'Bogor': CityCoordinates(lat: -6.5971, lng: 106.7910, province: 'Jawa Barat', city: 'Kota Bogor'),
    'Bandung': CityCoordinates(lat: -6.9147, lng: 107.6098, province: 'Jawa Barat', city: 'Kota Bandung'),
    'Bekasi': CityCoordinates(lat: -6.2349, lng: 107.0015, province: 'Jawa Barat', city: 'Kota Bekasi'),
    'Tangerang': CityCoordinates(lat: -6.1778, lng: 106.6368, province: 'Banten', city: 'Kota Tangerang'),
    'Serang': CityCoordinates(lat: -6.4065, lng: 106.1507, province: 'Banten', city: 'Kota Serang'),
    'Semarang': CityCoordinates(lat: -6.9662, lng: 110.4192, province: 'Jawa Tengah', city: 'Kota Semarang'),
    'Yogyakarta': CityCoordinates(lat: -7.7956, lng: 110.3695, province: 'DI Yogyakarta', city: 'Kota Yogyakarta'),
    'Surakarta': CityCoordinates(lat: -7.5506, lng: 110.8140, province: 'Jawa Tengah', city: 'Kota Surakarta'),
    'Surabaya': CityCoordinates(lat: -7.2506, lng: 112.7508, province: 'Jawa Timur', city: 'Kota Surabaya'),
    'Malang': CityCoordinates(lat: -7.9797, lng: 112.6304, province: 'Jawa Timur', city: 'Kota Malang'),
    'Gresik': CityCoordinates(lat: -7.1667, lng: 112.6667, province: 'Jawa Timur', city: 'Kota Gresik'),
    
    // Sumatra
    'Medan': CityCoordinates(lat: 3.5952, lng: 98.6722, province: 'Sumatera Utara', city: 'Kota Medan'),
    'Pematangsiantar': CityCoordinates(lat: 2.6342, lng: 99.0567, province: 'Sumatera Utara', city: 'Kota Pematangsiantar'),
    'Palembang': CityCoordinates(lat: -2.9760, lng: 104.7530, province: 'Sumatera Selatan', city: 'Kota Palembang'),
    'Jambi': CityCoordinates(lat: -1.5898, lng: 103.6109, province: 'Jambi', city: 'Kota Jambi'),
    'Pekanbaru': CityCoordinates(lat: 0.5033, lng: 101.4487, province: 'Riau', city: 'Kota Pekanbaru'),
    'Padang': CityCoordinates(lat: -0.9492, lng: 100.4172, province: 'Sumatera Barat', city: 'Kota Padang'),
    'Banda Aceh': CityCoordinates(lat: 5.5577, lng: 95.3222, province: 'Aceh', city: 'Kota Banda Aceh'),
    'Bandar Lampung': CityCoordinates(lat: -5.3971, lng: 105.2668, province: 'Lampung', city: 'Bandar Lampung'),
    
    // Kalimantan
    'Banjarmasin': CityCoordinates(lat: -3.3286, lng: 114.5894, province: 'Kalimantan Selatan', city: 'Kota Banjarmasin'),
    'Palangkaraya': CityCoordinates(lat: -2.2167, lng: 113.9167, province: 'Kalimantan Tengah', city: 'Kota Palangkaraya'),
    'Samarinda': CityCoordinates(lat: -0.4948, lng: 117.1564, province: 'Kalimantan Timur', city: 'Kota Samarinda'),
    'Balikpapan': CityCoordinates(lat: -1.2654, lng: 116.8254, province: 'Kalimantan Timur', city: 'Kota Balikpapan'),
    'Pontianak': CityCoordinates(lat: -0.0263, lng: 109.3425, province: 'Kalimantan Barat', city: 'Kota Pontianak'),
    
    // Sulawesi
    'Makassar': CityCoordinates(lat: -5.1477, lng: 119.4327, province: 'Sulawesi Selatan', city: 'Kota Makassar'),
    'Manado': CityCoordinates(lat: 1.4748, lng: 124.8789, province: 'Sulawesi Utara', city: 'Kota Manado'),
    'Palu': CityCoordinates(lat: -0.9020, lng: 119.8707, province: 'Sulawesi Tengah', city: 'Kota Palu'),
    'Kendari': CityCoordinates(lat: -3.9701, lng: 122.5841, province: 'Sulawesi Tenggara', city: 'Kota Kendari'),
    'Gorontalo': CityCoordinates(lat: 0.5421, lng: 123.0554, province: 'Gorontalo', city: 'Kota Gorontalo'),
    
    // Bali & NTT & NTB
    'Denpasar': CityCoordinates(lat: -8.6705, lng: 115.2126, province: 'Bali', city: 'Kota Denpasar'),
    'Mataram': CityCoordinates(lat: -8.5898, lng: 116.1256, province: 'Nusa Tenggara Barat', city: 'Kota Mataram'),
    'Kupang': CityCoordinates(lat: -10.1699, lng: 123.6047, province: 'Nusa Tenggara Timur', city: 'Kota Kupang'),
    
    // Papua
    'Jayapura': CityCoordinates(lat: -2.5898, lng: 140.6592, province: 'Papua', city: 'Kota Jayapura'),
    'Manokwari': CityCoordinates(lat: -0.8667, lng: 134.0833, province: 'Papua Barat', city: 'Kota Manokwari'),
  };

  /// Find closest city based on latitude and longitude
  static Map<String, String>? findClosestCity(double latitude, double longitude) {
    double minDistance = double.infinity;
    CityCoordinates? closestCity;

    for (final city in majorCities.values) {
      final distance = _calculateDistance(latitude, longitude, city.lat, city.lng);
      if (distance < minDistance) {
        minDistance = distance;
        closestCity = city;
      }
    }

    if (closestCity != null && minDistance < 200) { // Expand threshold to 200km
      return {
        'province': closestCity.province,
        'city': closestCity.city,
      };
    }

    return null;
  }

  /// Haversine formula to calculate distance between two coordinates (in km)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);

    // Using dart:math for accurate trigonometry
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

class CityCoordinates {
  final double lat;
  final double lng;
  final String province;
  final String city;

  const CityCoordinates({
    required this.lat,
    required this.lng,
    required this.province,
    required this.city,
  });
}
