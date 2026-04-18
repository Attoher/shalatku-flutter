import 'package:cloud_firestore/cloud_firestore.dart';

class IbadahLog {
  final String? id;
  final String userId;
  final String type;
  final String notes;
  final DateTime date;
  final bool completed;

  IbadahLog({
    this.id,
    required this.userId,
    required this.type,
    this.notes = '',
    required this.date,
    this.completed = true,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'notes': notes,
        'date': Timestamp.fromDate(date),
        'completed': completed,
      };

  factory IbadahLog.fromMap(Map<String, dynamic> map, String id) => IbadahLog(
        id: id,
        userId: map['userId'] ?? '',
        type: map['type'] ?? '',
        notes: map['notes'] ?? '',
        date: (map['date'] as Timestamp).toDate(),
        completed: map['completed'] ?? true,
      );

  IbadahLog copyWith({
    String? id,
    String? type,
    String? notes,
    DateTime? date,
    bool? completed,
  }) =>
      IbadahLog(
        id: id ?? this.id,
        userId: userId,
        type: type ?? this.type,
        notes: notes ?? this.notes,
        date: date ?? this.date,
        completed: completed ?? this.completed,
      );
}
