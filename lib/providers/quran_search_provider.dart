import 'package:flutter/material.dart';
import '../models/quran_vector_model.dart';
import '../services/quran_vector_service.dart';

class QuranSearchProvider extends ChangeNotifier {
  final QuranVectorService _service = QuranVectorService();

  List<QuranVectorResult> _results = [];
  bool _loading = false;
  String? _error;
  String _lastQuery = '';

  List<QuranVectorResult> get results => _results;
  bool get loading => _loading;
  String? get error => _error;
  String get lastQuery => _lastQuery;

  Future<void> search(String query, {List<String>? types}) async {
    if (query.trim().isEmpty) return;
    
    _loading = true;
    _error = null;
    _lastQuery = query;
    notifyListeners();

    try {
      final response = await _service.search(query: query, types: types);
      _results = response.hasil;
      if (_results.isEmpty) {
        _error = 'Tidak ada hasil yang ditemukan untuk "$query"';
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _results = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _results = [];
    _error = null;
    _lastQuery = '';
    notifyListeners();
  }
}
