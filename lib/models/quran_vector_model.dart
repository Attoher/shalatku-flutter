class QuranVectorResponse {
  final String status;
  final String cari;
  final int jumlah;
  final List<QuranVectorResult> hasil;

  QuranVectorResponse({
    required this.status,
    required this.cari,
    required this.jumlah,
    required this.hasil,
  });

  factory QuranVectorResponse.fromJson(Map<String, dynamic> json) {
    return QuranVectorResponse(
      status: json['status'] ?? '',
      cari: json['cari'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      hasil: (json['hasil'] as List?)
              ?.map((e) => QuranVectorResult.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class QuranVectorResult {
  final String tipe;
  final double skor;
  final String relevansi;
  final Map<String, dynamic> data;

  QuranVectorResult({
    required this.tipe,
    required this.skor,
    required this.relevansi,
    required this.data,
  });

  factory QuranVectorResult.fromJson(Map<String, dynamic> json) {
    return QuranVectorResult(
      tipe: json['tipe'] ?? '',
      skor: (json['skor'] as num?)?.toDouble() ?? 0.0,
      relevansi: json['relevansi'] ?? '',
      data: json['data'] ?? {},
    );
  }

  // Helper getters for different types
  String get title {
    switch (tipe) {
      case 'ayat':
        return '${data['nama_surat']} [${data['nomor_ayat']}]';
      case 'tafsir':
        return 'Tafsir ${data['nama_surat']} [${data['nomor_ayat']}]';
      case 'surat':
        return data['nama'] ?? data['nama_surat'] ?? 'Surat';
      case 'doa':
        return data['judul'] ?? 'Doa';
      default:
        return 'Hasil';
    }
  }

  String get content {
    switch (tipe) {
      case 'ayat':
        return data['terjemahan_id'] ?? '';
      case 'tafsir':
        return data['isi'] ?? '';
      case 'surat':
        return data['deskripsi'] ?? data['arti'] ?? '';
      case 'doa':
        return data['terjemahan'] ?? data['arti'] ?? '';
      default:
        return '';
    }
  }

  String get arabic {
    switch (tipe) {
      case 'ayat':
        return data['teks_arab'] ?? '';
      case 'surat':
        return data['nama_arab'] ?? data['nama_surat_arab'] ?? '';
      case 'doa':
        return data['teks_arab'] ?? data['arab'] ?? '';
      default:
        return '';
    }
  }

  String get latin {
    switch (tipe) {
      case 'ayat':
        return data['teks_latin'] ?? '';
      case 'doa':
        return data['teks_latin'] ?? '';
      default:
        return '';
    }
  }

  int? get surahNumber {
    if (tipe == 'surat') return data['nomor'];
    if (tipe == 'ayat' || tipe == 'tafsir') return data['id_surat'];
    return null;
  }

  int? get ayatNumber {
    if (tipe == 'ayat' || tipe == 'tafsir') return data['nomor_ayat'];
    return null;
  }
}
