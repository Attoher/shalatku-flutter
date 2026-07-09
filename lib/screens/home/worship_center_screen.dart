import 'package:flutter/material.dart';
import '../prayer_times/prayer_times_screen.dart';
import '../qibla/qibla_screen.dart';
import '../ibadah/ibadah_log_screen.dart';

class WorshipCenterScreen extends StatelessWidget {
  const WorshipCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pusat Ibadah', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.primaryContainer],
              ),
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Tab(icon: Icon(Icons.schedule), text: 'Jadwal'),
              Tab(icon: Icon(Icons.explore), text: 'Kiblat'),
              Tab(icon: Icon(Icons.book), text: 'Log'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PrayerTimesScreen(hideAppBar: true),
            QiblaScreen(hideAppBar: true),
            IbadahLogScreen(hideAppBar: true),
          ],
        ),
      ),
    );
  }
}
