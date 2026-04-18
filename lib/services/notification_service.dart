import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_time_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static Future<bool> _isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? true;
  }

  static Future<void> schedulePrayerNotifications(
      List<PrayerTimeModel> prayers) async {
    final enabled = await _isNotificationsEnabled();
    if (!enabled) return;

    await _plugin.cancelAll();
    
    // Map prayer names to emoji and descriptions
    const prayerEmoji = {
      'Imsak': '🌙 Waktu Imsak - Jangan lupa berbuka puasa!',
      'Subuh': '🌅 Waktu Subuh - Shalat Subuh telah tiba',
      'Terbit': '🌅 Waktu Terbit - Matahari terbit',
      'Dhuha': '☀️ Waktu Dhuha - Shalat Dhuha',
      'Dzuhur': '🌤️ Waktu Dzuhur - Shalat Dzuhur telah tiba',
      'Ashar': '🌥️ Waktu Ashar - Shalat Ashar telah tiba',
      'Maghrib': '🌇 Waktu Maghrib - Shalat Maghrib telah tiba',
      'Isya': '🌙 Waktu Isya - Shalat Isya telah tiba',
    };
    
    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      if (prayer.time.isAfter(DateTime.now())) {
        await _plugin.zonedSchedule(
          i,
          '🕌 ${prayer.name}',
          prayerEmoji[prayer.name] ?? 'Waktunya shalat ${prayer.name}',
          tz.TZDateTime.from(prayer.time, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'adzan_channel',
              'Jadwal Shalat',
              channelDescription: 'Notifikasi jadwal shalat dan waktu penting',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  static Future<void> showIbadahReminder() async {
    final enabled = await _isNotificationsEnabled();
    if (!enabled) return;

    await _plugin.show(
      99,
      '📿 Jangan Lupa Dzikir!',
      'Luangkan waktu untuk berdzikir hari ini',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ibadah_channel',
          'Pengingat Ibadah',
          channelDescription: 'Pengingat ibadah harian',
          importance: Importance.defaultImportance,
        ),
      ),
    );
  }
}
