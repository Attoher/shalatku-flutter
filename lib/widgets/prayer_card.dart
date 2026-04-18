import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_time_model.dart';
import '../utils/theme.dart';

class PrayerCard extends StatelessWidget {
  final PrayerTimeModel prayer;

  const PrayerCard({super.key, required this.prayer});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(prayer.time);

    Color bgColor = Colors.white;
    Color textColor = AppTheme.textDark;
    Widget? badge;

    if (prayer.isNext) {
      bgColor = AppTheme.primary;
      textColor = Colors.white;
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'BERIKUTNYA',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else if (prayer.isPassed) {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: prayer.isNext
            ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (badge != null) ...[badge, const SizedBox(height: 4)],
          Text(
            prayer.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (prayer.isPassed)
            Icon(Icons.check_circle, color: Colors.green.shade400, size: 16),
        ],
      ),
    );
  }
}
