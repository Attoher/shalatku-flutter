import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_model.dart';

class QuranService {
  static const String _baseUrl = 'https://equran.id/api/v2';

  Future<List<SurahModel>> getSurahList() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/surat'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> surahList = data['data'];
        return surahList.map((json) => SurahModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar surat');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<SurahDetailModel> getSurahDetail(int nomor) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/surat/$nomor'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return SurahDetailModel.fromJson(data['data']);
      } else {
        throw Exception('Gagal memuat detail surat $nomor');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
