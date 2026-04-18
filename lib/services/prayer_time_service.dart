import 'package:geolocator/geolocator.dart';
import '../models/prayer_time_model.dart';
import 'equran_api_service.dart';
import 'location_mapping_service.dart';

class PrayerTimeService {
  final EquranApiService _apiService = EquranApiService();

  /// Get prayer times from EQuran.id API using location
  Future<List<PrayerTimeModel>> getPrayerTimesFromLocation(Position position) async {
    try {
      // Map location to province and city
      final locationMap = LocationMappingService.findClosestCity(
        position.latitude,
        position.longitude,
      );

      if (locationMap == null) {
        throw Exception('Lokasi tidak ditemukan. Silakan coba kota yang lebih besar.');
      }

      // Fetch prayer schedule from API
      final schedule = await _apiService.getPrayerSchedule(
        province: locationMap['province']!,
        city: locationMap['city']!,
      );

      // Get today's date
      final now = DateTime.now();
      final todaySchedule = schedule.data.jadwal.firstWhere(
        (j) => j.tanggal == now.day,
        orElse: () => schedule.data.jadwal.first,
      );

      // Convert to PrayerTimeModel
      final times = <PrayerTimeModel>[
        _createModel('Imsak', todaySchedule.imsak, now),
        _createModel('Subuh', todaySchedule.subuh, now),
        _createModel('Terbit', todaySchedule.terbit, now),
        _createModel('Dhuha', todaySchedule.dhuha, now),
        _createModel('Dzuhur', todaySchedule.dzuhur, now),
        _createModel('Ashar', todaySchedule.ashar, now),
        _createModel('Maghrib', todaySchedule.maghrib, now),
        _createModel('Isya', todaySchedule.isya, now),
      ];

      // Mark passed and next prayer
      bool nextSet = false;
      return times.map((t) {
        final passed = now.isAfter(t.time);
        final isNext = !passed && !nextSet;
        if (isNext) nextSet = true;
        return PrayerTimeModel(
          name: t.name,
          time: t.time,
          isPassed: passed,
          isNext: isNext,
        );
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data jadwal shalat: $e');
    }
  }

  /// Helper to create model from time string (HH:mm)
  PrayerTimeModel _createModel(String name, String timeStr, DateTime today) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final time = DateTime(today.year, today.month, today.day, hour, minute);
    return PrayerTimeModel(
      name: name,
      time: time,
      isPassed: false,
      isNext: false,
    );
  }

  /// Get next prayer from list
  PrayerTimeModel? getNextPrayer(List<PrayerTimeModel> times) {
    for (final t in times) {
      if (t.isNext) return t;
    }
    return null;
  }

  /// Calculate time until next prayer
  Duration timeUntilNextPrayer(PrayerTimeModel? next) {
    if (next == null) return Duration.zero;
    final diff = next.time.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}
