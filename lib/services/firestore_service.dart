import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ibadah_log.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Reference ke subcollection ibadah_logs dari specific user
  CollectionReference _ibadahCol(String userId) =>
      _db.collection('users').doc(userId).collection('ibadah_logs');

  // CREATE
  Future<void> addIbadah(String userId, IbadahLog log) =>
      _ibadahCol(userId).add(log.toMap());

  // READ - stream logs by user, ordered by date
  Stream<List<IbadahLog>> getIbadahLogs(String userId) =>
      _ibadahCol(userId)
          .snapshots()
          .map((snap) {
        final docs = snap.docs
            .map((doc) => IbadahLog.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        // Sort in client to maintain order
        docs.sort((a, b) => b.date.compareTo(a.date));
        return docs;
      });

  // READ - logs for a specific date
  Stream<List<IbadahLog>> getIbadahByDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _ibadahCol(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => IbadahLog.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // UPDATE
  Future<void> updateIbadah(String userId, IbadahLog log) =>
      _ibadahCol(userId).doc(log.id).update(log.toMap());

  // DELETE
  Future<void> deleteIbadah(String userId, String id) =>
      _ibadahCol(userId).doc(id).delete();

  // Check if same ibadah type already exists on the same date
  Future<bool> hasSameTypeOnDate(String userId, String type, DateTime date, {String? excludeId}) async {
    final snap = await _ibadahCol(userId)
        .where('type', isEqualTo: type)
        .get();
    
    // Filter by date on client side
    final filtered = snap.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final logDate = (data['date'] as Timestamp).toDate();
      return logDate.year == date.year && 
             logDate.month == date.month && 
             logDate.day == date.day;
    }).toList();
    
    // If excludeId is provided (for edit mode), exclude that document
    if (excludeId != null) {
      return filtered.any((doc) => doc.id != excludeId);
    }
    
    return filtered.isNotEmpty;
  }

  // Stats: count per type for current month
  Future<Map<String, int>> getMonthlyStats(String userId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    final snap = await _ibadahCol(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .get();

    final Map<String, int> stats = {};
    for (var doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data['type'] as String;
      stats[type] = (stats[type] ?? 0) + 1;
    }
    return stats;
  }
}
