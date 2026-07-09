import 'package:flutter/material.dart';
import '../models/quran_model.dart';
import '../services/quran_service.dart';

class QuranProvider with ChangeNotifier {
  final QuranService _service = QuranService();
  
  List<SurahModel> _surahs = [];
  List<SurahModel> get surahs => _surahs;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  SurahDetailModel? _currentSurah;
  SurahDetailModel? get currentSurah => _currentSurah;

  bool _isMushafMode = false;
  bool get isMushafMode => _isMushafMode;

  void toggleMushafMode() {
    _isMushafMode = !_isMushafMode;
    notifyListeners();
  }

  Future<void> fetchSurahs() async {
    if (_surahs.isNotEmpty) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _service.getSurahList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSurahDetail(int nomor) async {
    _isLoading = true;
    _error = null;
    _currentSurah = null;
    notifyListeners();

    try {
      _currentSurah = await _service.getSurahDetail(nomor);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<SurahModel> searchSurah(String query) {
    if (query.isEmpty) return _surahs;
    return _surahs.where((s) => 
      s.namaLatin.toLowerCase().contains(query.toLowerCase()) ||
      s.arti.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
