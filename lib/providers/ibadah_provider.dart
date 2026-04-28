import 'package:flutter/material.dart';
import '../models/ibadah_log.dart';
import '../services/firestore_service.dart';

class IbadahProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  final List<IbadahLog> _logs = [];
  Map<String, int> _monthlyStats = {};
  final bool _loading = false;
  DateTime _selectedDate = DateTime.now();

  List<IbadahLog> get logs => _logs;
  Map<String, int> get monthlyStats => _monthlyStats;
  bool get loading => _loading;
  DateTime get selectedDate => _selectedDate;

  Stream<List<IbadahLog>> watchAllLogs(String userId) =>
      _service.getIbadahLogs(userId);

  Stream<List<IbadahLog>> watchDailyLogs(String userId, DateTime date) =>
      _service.getIbadahByDate(userId, date);

  Future<void> addIbadah(String userId, IbadahLog log) => _service.addIbadah(userId, log);
  Future<void> updateIbadah(String userId, IbadahLog log) => _service.updateIbadah(userId, log);
  Future<void> deleteIbadah(String userId, String id) => _service.deleteIbadah(userId, id);
  Future<bool> hasSameTypeOnDate(String userId, String type, DateTime date, {String? excludeId}) =>
      _service.hasSameTypeOnDate(userId, type, date, excludeId: excludeId);

  Future<void> loadMonthlyStats(String userId) async {
    try {
      _monthlyStats = await _service.getMonthlyStats(userId);
    } catch (e) {
      _monthlyStats = {};
    }
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}
