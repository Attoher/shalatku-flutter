import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/prayer_provider.dart';
import '../../utils/theme.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Shalat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PrayerProvider>().loadData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<PrayerProvider>().loadData(),
        child: prayer.loading
            ? const Center(child: CircularProgressIndicator())
            : prayer.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 60, color: AppTheme.textGrey),
                        const SizedBox(height: 16),
                        Text(prayer.error!, style: const TextStyle(color: AppTheme.textGrey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<PrayerProvider>().loadData(),
                          child: const Text('Izinkan Lokasi'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (prayer.position != null)
                        Card(
                          color: AppTheme.primary,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  '${prayer.position!.latitude.toStringAsFixed(4)}, ${prayer.position!.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ...prayer.prayerTimes.map((p) {
                        final isNext = p.isNext;
                        final isPassed = p.isPassed;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isNext ? AppTheme.primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isNext ? null : Border.all(color: Colors.grey.shade200),
                            boxShadow: isNext
                                ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 8)]
                                : null,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: isNext
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : AppTheme.primary.withValues(alpha: 0.1),
                              child: Icon(
                                isPassed ? Icons.check : Icons.access_time,
                                color: isNext ? Colors.white : isPassed ? Colors.green : AppTheme.primary,
                              ),
                            ),
                            title: Text(
                              p.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isNext ? Colors.white : AppTheme.textDark,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: isNext
                                ? Text(
                                    'Shalat berikutnya',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                                  )
                                : null,
                            trailing: Text(
                              DateFormat('HH:mm').format(p.time),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: isNext ? AppTheme.accent : isPassed ? Colors.grey : AppTheme.textDark,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
      ),
    );
  }
}
