import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
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
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    
    // Create notification channels
    await _createNotificationChannels();
    
    // Request notification permission (Android 13+)
    await _requestNotificationPermission();
    
    // Setup foreground notification handler
    await _setupForegroundNotifications();
    
    _initialized = true;
  }

  static Future<void> _setupForegroundNotifications() async {
    // Listen to notifications when app is in foreground
    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationResponse(NotificationResponse notificationResponse) {
    print('Notification tapped: ${notificationResponse.payload}');
  }

  static Future<void> _createNotificationChannels() async {
    // Create prayer notification channel
    const androidChannel = AndroidNotificationChannel(
      'adzan_channel',
      'Jadwal Shalat',
      description: 'Notifikasi jadwal shalat dan waktu penting',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Create ibadah reminder channel
    const ibadahChannel = AndroidNotificationChannel(
      'ibadah_channel',
      'Pengingat Ibadah',
      description: 'Pengingat ibadah harian',
      importance: Importance.defaultImportance,
      showBadge: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(ibadahChannel);
  }

  static Future<void> _requestNotificationPermission() async {
    // Request POST_NOTIFICATIONS permission for Android 13+
    final status = await Permission.notification.request();
    if (status.isDenied) {
      print('Notification permission denied');
    } else if (status.isGranted) {
      print('Notification permission granted');
    } else if (status.isPermanentlyDenied) {
      print('Notification permission permanently denied, opening app settings');
      openAppSettings();
    }
    
    // Request SCHEDULE_EXACT_ALARM permission
    final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
    if (exactAlarmStatus.isGranted) {
      print('Schedule exact alarm permission granted');
    } else {
      print('Schedule exact alarm permission: ${exactAlarmStatus.toString()}');
    }
  }

  static Future<bool> _isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? true;
  }

  /// Check and show notification if it's prayer time (call periodically from app)
  static Future<void> checkAndShowPrayerNotifications(List<PrayerTimeModel> prayers) async {
    final enabled = await _isNotificationsEnabled();
    if (!enabled) {
      print('Notifications disabled by user');
      return;
    }

    final now = DateTime.now();
    
    // Map prayer names to descriptions
    const prayerDescriptions = {
      'Imsak': 'Jangan lupa berbuka puasa!',
      'Subuh': 'Shalat Subuh telah tiba',
      'Terbit': 'Matahari terbit',
      'Dhuha': 'Shalat Dhuha',
      'Dzuhur': 'Shalat Dzuhur telah tiba',
      'Ashar': 'Shalat Ashar telah tiba',
      'Maghrib': 'Shalat Maghrib telah tiba',
      'Isya': 'Shalat Isya telah tiba',
    };

    // Check each prayer time
    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      
      // Check if current time is within 1 minute of prayer time
      final timeDiff = prayer.time.difference(now);
      final minutos = timeDiff.inSeconds;
      
      if (minutos >= -60 && minutos <= 0) {
        // Prayer time has arrived! Show notification
        print('PRAYER TIME: ${prayer.name} is now! Showing notification...');
        try {
          await _plugin.show(
            i,
            'Waktu ${prayer.name}',
            prayerDescriptions[prayer.name] ?? 'Waktunya shalat ${prayer.name}',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'adzan_channel',
                'Jadwal Shalat',
                channelDescription: 'Notifikasi jadwal shalat dan waktu penting',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
                tag: 'shalat_${prayer.name}',
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentSound: true,
              ),
            ),
          );
          print('SUCCESS: Notification shown for ${prayer.name}');
        } catch (e) {
          print('ERROR showing notification for ${prayer.name}: $e');
        }
      }
    }
  }

  static Future<void> showIbadahReminder() async {
    final enabled = await _isNotificationsEnabled();
    if (!enabled) return;

    await _plugin.show(
      99,
      'Pengingat Ibadah',
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

  /// Test notification - shows immediately to verify notifications work
  static Future<void> showTestNotification() async {
    print('Showing test notification immediately...');
    try {
      await _plugin.show(
        9999,
        'TEST: ShalatKu Notification',
        'If you see this, notifications are working! Current time: ${DateTime.now()}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adzan_channel',
            'Jadwal Shalat',
            channelDescription: 'Notifikasi jadwal shalat dan waktu penting',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
      );
      print('Test notification showed successfully');
    } catch (e) {
      print('ERROR showing test notification: $e');
    }
  }
}
