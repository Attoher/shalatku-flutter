import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import '../../providers/prayer_provider.dart';
import '../../utils/theme.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: prayer.loading
          ? const Center(child: CircularProgressIndicator())
          : prayer.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 60, color: AppTheme.textGrey),
                      const SizedBox(height: 16),
                      Text(prayer.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textGrey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<PrayerProvider>().loadData(),
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
                      compassHeading = snapshot.data!.heading!;
                    }

                    final qiblaAngle = prayer.qiblaDirection;
                    final needleAngle = (qiblaAngle - compassHeading) * (math.pi / 180);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Compass Container
                          Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Compass rose background
                                Transform.rotate(
                                  angle: -compassHeading * (math.pi / 180),
                                  child: CustomPaint(
                                    size: const Size(280, 280),
                                    painter: _CompassRosePainter(),
                                  ),
                                ),
                                // Qibla needle
                                Transform.rotate(
                                  angle: needleAngle,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [AppTheme.primary, Color(0xFF81C784)],
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const Icon(Icons.mosque, color: AppTheme.primary, size: 32),
                                      Container(
                                        width: 8,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Center dot
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Info cards
                          Row(
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.explore,
                                  label: 'Arah Kiblat',
                                  value: '${qiblaAngle.toStringAsFixed(1)}°',
                                  subtitle: 'dari Utara',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _InfoCard(
                                  icon: Icons.navigation,
                                  label: 'Kompas',
                                  value: '${compassHeading.toStringAsFixed(1)}°',
                                  subtitle: 'heading saat ini',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: AppTheme.primary),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Arahkan ikon masjid ke depan Anda untuk menghadap kiblat.',
                                    style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
          ],
        ),
      ),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final circlePaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    final borderPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw tick marks
    final tickPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      final isMajor = i % 90 == 0;
      final tickLen = isMajor ? 16.0 : 8.0;
      final start = Offset(
        center.dx + (radius - tickLen) * math.sin(angle),
        center.dy - (radius - tickLen) * math.cos(angle),
      );
      final end = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );
      canvas.drawLine(start, end, tickPaint..strokeWidth = isMajor ? 2.5 : 1.0);
    }

    // Draw cardinal labels
    final labels = {'U': 0.0, 'T': math.pi / 2, 'S': math.pi, 'B': -math.pi / 2};
    labels.forEach((label, angle) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: label == 'U' ? Colors.red : AppTheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final pos = Offset(
        center.dx + (radius - 30) * math.sin(angle) - textPainter.width / 2,
        center.dy - (radius - 30) * math.cos(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, pos);
    });
  }

  @override
  bool shouldRepaint(_CompassRosePainter _) => false;
}
