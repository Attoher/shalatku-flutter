import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quran_vector_model.dart';

class QuranVectorService {
  static const String baseUrl = 'https://equran.id/api/vector';

  Future<QuranVectorResponse> search({
    required String query,
    int limit = 10,
    List<String>? types,
    double minScore = 0.0,
  }) async {
    try {
      final requestBody = {
        'cari': query,
        'batas': limit,
        'tipe': types ?? ['ayat', 'tafsir', 'surat', 'doa'],
        'skorMin': minScore,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return QuranVectorResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Gagal melakukan pencarian AI (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat pencarian AI: $e');
    }
  }
}
