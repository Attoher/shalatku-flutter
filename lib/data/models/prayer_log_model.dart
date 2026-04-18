import 'package:cloud_firestore/cloud_firestore.dart';

enum IbadahType {
  subuh('Subuh', '🕌'),
  dzuhur('Dzuhur', '🕌'),
  ashar('Ashar', '🕌'),
  maghrib('Maghrib', '🕌'),
  isya('Isya', '🕌'),
  tahajud('Tahajud', '🌙'),
  dhuha('Dhuha', '☀️'),
  witir('Witir', '⭐'),
  quran('Baca Al-Quran', '📖'),
  dzikir('Dzikir', '📿'),
  sedekah('Sedekah', '💝'),
  puasaSunnah('Puasa Sunnah', '🌙');

  const IbadahType(this.label, this.emoji);
  final String label;
  final String emoji;
}

class PrayerLogModel {
  final String id;
  final String userId;
  final IbadahType type;
  final DateTime date;
  final bool isCompleted;
  final String? notes;
  final int? duration; // dalam menit (opsional)
  final DateTime createdAt;
  final DateTime? updatedAt;

  PrayerLogModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.isCompleted,
    this.notes,
    this.duration,
    required this.createdAt,
    this.updatedAt,
  });

  factory PrayerLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrayerLogModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: IbadahType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => IbadahType.subuh,
      ),
      date: (data['date'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      notes: data['notes'],
      duration: data['duration'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'isCompleted': isCompleted,
      'notes': notes,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  PrayerLogModel copyWith({
    String? id,
    String? userId,
    IbadahType? type,
    DateTime? date,
    bool? isCompleted,
    String? notes,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrayerLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
