import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/equran_api_model.dart';

class EquranApiService {
  static const String baseUrl = 'https://equran.id/api/v2/shalat';

  /// Get list of provinces
  Future<List<String>> getProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/provinsi'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = ProvinceResponse.fromJson(jsonDecode(response.body));
        return data.data;
      }
      throw Exception('Failed to fetch provinces');
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  /// Get list of cities/districts by province
  Future<List<String>> getCities(String province) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kabkota'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'provinsi': province}),
      );

      if (response.statusCode == 200) {
        final data = CityResponse.fromJson(jsonDecode(response.body));
        return data.data;
      }
      throw Exception('Failed to fetch cities');
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }

  /// Get prayer times schedule for a city
  Future<PrayerScheduleResponse> getPrayerSchedule({
    required String province,
    required String city,
    int? month,
    int? year,
  }) async {
    try {
      final now = DateTime.now();
      final requestBody = {
        'provinsi': province,
        'kabkota': city,
        'bulan': month ?? now.month,
        'tahun': year ?? now.year,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return PrayerScheduleResponse.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to fetch prayer schedule');
    } catch (e) {
      throw Exception('Error fetching prayer schedule: $e');
    }
  }
}
