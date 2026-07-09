import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/prayer_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  final bool hideAppBar;
  const PrayerTimesScreen({super.key, this.hideAppBar = false});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerProvider>();

    Widget body = RefreshIndicator(
      onRefresh: () => context.read<PrayerProvider>().loadData(),
      child: Scrollbar(
        child: CustomScrollView(
          slivers: [
          if (!widget.hideAppBar)
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Jadwal Shalat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.primaryContainer],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        Icons.access_time,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<PrayerProvider>().loadData(),
                ),
              ],
            ),
          SliverToBoxAdapter(
            child: prayer.loading
                ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
                : prayer.error != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
                        child: Column(
                          children: [
                            Icon(Icons.location_off, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(height: 24),
                            Text(prayer.error!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () async {
                                if (_isRequesting) return;
                                setState(() => _isRequesting = true);
                                try {
                                  debugPrint('PrayerTimes: Requesting location...');
                                  final status = await Permission.locationWhenInUse.request();
                                  if (status.isPermanentlyDenied) {
                                    if (context.mounted) {
                                      _showSettingsDialog(context, 'Lokasi');
                                    }
                                  } else if (status.isGranted) {
                                    if (context.mounted) {
                                      context.read<PrayerProvider>().loadData();
                                    }
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isRequesting = false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Izinkan Lokasi'),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (prayer.position != null)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Lokasi Anda', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                          Text(
                                            '${prayer.position!.latitude.toStringAsFixed(4)}, ${prayer.position!.longitude.toStringAsFixed(4)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),
                            ...prayer.prayerTimes.map((p) {
                              final isNext = p.isNext;
                              final isPassed = p.isPassed;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isNext ? Theme.of(context).primaryColor : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isNext
                                      ? [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isNext ? Colors.white.withValues(alpha: 0.2) : Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPassed ? Icons.check_circle : Icons.access_time_filled,
                                      color: isNext ? Colors.white : isPassed ? Colors.green : Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    p.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isNext ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: isNext
                                      ? const Text('Shalat Berikutnya', style: TextStyle(color: Colors.white70, fontSize: 11))
                                      : null,
                                  trailing: Text(
                                    DateFormat('HH:mm').format(p.time),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: isNext ? Theme.of(context).colorScheme.secondary : isPassed ? Colors.grey.shade400 : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    ),
  );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: body,
    );
  }

  void _showSettingsDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Izin $permissionName Ditolak'),
        content: Text('Anda telah menolak izin $permissionName secara permanen. Silakan aktifkan secara manual di Pengaturan Aplikasi agar fitur ini dapat digunakan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }
}
