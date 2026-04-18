class PrayerTimeModel {
  final String name;
  final DateTime time;
  final bool isPassed;
  final bool isNext;

  PrayerTimeModel({
    required this.name,
    required this.time,
    required this.isPassed,
    required this.isNext,
  });
}
