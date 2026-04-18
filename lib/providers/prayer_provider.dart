import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_time_model.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';

class PrayerProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final PrayerTimeService _prayerService = PrayerTimeService();

  Position? _position;
  List<PrayerTimeModel> _prayerTimes = [];
  double _qiblaDirection = 0;
  bool _loading = false;
  String? _error;

  Position? get position => _position;
  List<PrayerTimeModel> get prayerTimes => _prayerTimes;
  double get qiblaDirection => _qiblaDirection;
  bool get loading => _loading;
  String? get error => _error;

  PrayerTimeModel? get nextPrayer =>
      _prayerService.getNextPrayer(_prayerTimes);

  Duration get timeUntilNext =>
      _prayerService.timeUntilNextPrayer(nextPrayer);

  Future<void> loadData() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _position = await _locationService.getCurrentPosition();
      if (_position == null) {
        _error = 'Izin lokasi diperlukan untuk menampilkan jadwal shalat';
        return;
      }
      
      // Fetch prayer times from API
      _prayerTimes = await _prayerService.getPrayerTimesFromLocation(_position!);
      
      // Calculate Qibla direction
      _qiblaDirection = _locationService.calculateQiblaDirection(
        _position!.latitude,
        _position!.longitude,
      );
      
      // Schedule notifications
      await NotificationService.schedulePrayerNotifications(_prayerTimes);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
