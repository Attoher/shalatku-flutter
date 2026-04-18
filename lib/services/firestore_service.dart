import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ibadah_log.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _ibadahCol => _db.collection('ibadah_logs');

  // CREATE
  Future<void> addIbadah(IbadahLog log) =>
      _ibadahCol.add(log.toMap());

  // READ - stream logs by user, ordered by date (no index needed for single field)
  Stream<List<IbadahLog>> getIbadahLogs(String userId) =>
      _ibadahCol
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) {
        final docs = snap.docs
            .map((doc) => IbadahLog.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        // Sort in client to avoid needing composite index
        docs.sort((a, b) => b.date.compareTo(a.date));
        return docs;
      });

  // READ - logs for a specific date
  Stream<List<IbadahLog>> getIbadahByDate(String userId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _ibadahCol
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => IbadahLog.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // UPDATE
  Future<void> updateIbadah(IbadahLog log) =>
      _ibadahCol.doc(log.id).update(log.toMap());

  // DELETE
  Future<void> deleteIbadah(String id) => _ibadahCol.doc(id).delete();

  // Check if same ibadah type already exists on the same date
  Future<bool> hasSameTypeOnDate(String userId, String type, DateTime date, {String? excludeId}) async {
    // Simple query without date range - filter on client side
    final snap = await _ibadahCol
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type)
        .get();
    
    // Filter by date on client side to avoid index requirement
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

  // Stats: count per type for current month (no complex queries - filter in client)
  Future<Map<String, int>> getMonthlyStats(String userId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);

    // Simple single WHERE - no index needed
    final snap = await _ibadahCol
        .where('userId', isEqualTo: userId)
        .get();

    final Map<String, int> stats = {};
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      
      // Filter by month on client side
      if (date.isAfter(start.subtract(const Duration(days: 1))) && 
          date.isBefore(end.add(const Duration(days: 1)))) {
        final type = data['type'] as String;
        stats[type] = (stats[type] ?? 0) + 1;
      }
    }
    return stats;
  }
}
