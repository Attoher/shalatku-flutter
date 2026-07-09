import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import '../../providers/prayer_provider.dart';

class QiblaScreen extends StatefulWidget {
  final bool hideAppBar;
  const QiblaScreen({super.key, this.hideAppBar = false});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _smoothedHeading = 0;
  final double _filterFactor = 0.15;
  bool _isRequesting = false;

  double _smoothHeading(double newHeading) {
    double diff = newHeading - _smoothedHeading;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    _smoothedHeading += diff * _filterFactor;
    if (_smoothedHeading < 0) _smoothedHeading += 360;
    if (_smoothedHeading >= 360) _smoothedHeading -= 360;
    return _smoothedHeading;
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

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
          if (!widget.hideAppBar)
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Arah Kiblat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                      right: -30,
                      bottom: -30,
                      child: Icon(
                        Icons.explore,
                        size: 160,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
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
                                  debugPrint('Qibla: Requesting location...');
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
                    : StreamBuilder<CompassEvent>(
                        stream: FlutterCompass.events,
                        builder: (context, snapshot) {
                          double compassHeading = 0;
                          if (snapshot.hasData && snapshot.data!.heading != null) {
                            compassHeading = _smoothHeading(snapshot.data!.heading!);
                          }

                          final qiblaAngle = prayer.qiblaDirection;
                          final needleAngle = (qiblaAngle - compassHeading) * (math.pi / 180);

                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                // Compass UI
                                Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 5),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Transform.rotate(
                                        angle: -compassHeading * (math.pi / 180),
                                        child: CustomPaint(
                                          size: const Size(260, 260),
                                          painter: _CompassRosePainter(primaryColor: Theme.of(context).primaryColor),
                                        ),
                                      ),
                                      Transform.rotate(
                                        angle: needleAngle,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                                                ),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            ),
                                            Icon(Icons.mosque, color: Theme.of(context).primaryColor, size: 36),
                                            Container(
                                              width: 6,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // Info cards
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InfoCard(
                                        icon: Icons.explore_outlined,
                                        label: 'Arah Kiblat',
                                        value: '${qiblaAngle.toStringAsFixed(1)}°',
                                        subtitle: 'dari Utara',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _InfoCard(
                                        icon: Icons.navigation_outlined,
                                        label: 'Derajat Anda',
                                        value: '${compassHeading.toStringAsFixed(1)}°',
                                        subtitle: 'heading kompas',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.tips_and_updates_outlined, color: Theme.of(context).primaryColor, size: 24),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          'Arahkan ikon masjid ke garis depan untuk menghadap kiblat yang tepat.',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    ),
  );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  const _InfoCard({required this.icon, required this.label, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 26),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  final Color primaryColor;
  _CompassRosePainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final circlePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    final borderPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    final tickPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      final isMajor = i % 90 == 0;
      final tickLen = isMajor ? 12.0 : 6.0;
      final start = Offset(center.dx + (radius - tickLen) * math.sin(angle), center.dy - (radius - tickLen) * math.cos(angle));
      final end = Offset(center.dx + radius * math.sin(angle), center.dy - radius * math.cos(angle));
      canvas.drawLine(start, end, tickPaint..strokeWidth = isMajor ? 2.5 : 1.0);
    }

    final labels = {'U': 0.0, 'T': math.pi / 2, 'S': math.pi, 'B': -math.pi / 2};
    labels.forEach((label, angle) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: label == 'U' ? Colors.redAccent : primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final pos = Offset(center.dx + (radius - 28) * math.sin(angle) - textPainter.width / 2, center.dy - (radius - 28) * math.cos(angle) - textPainter.height / 2);
      textPainter.paint(canvas, pos);
    });
  }

  @override
  bool shouldRepaint(_CompassRosePainter _) => false;
}
