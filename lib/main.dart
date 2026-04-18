import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/ibadah_provider.dart';
import 'providers/prayer_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Firebase already initialized
  }
  
  await NotificationService.initialize();
  await initializeDateFormatting('id', null);

  runApp(const ShalatKuApp());
}

class ShalatKuApp extends StatelessWidget {
  const ShalatKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IbadahProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
      ],
      child: MaterialApp(
        title: 'ShalatKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
