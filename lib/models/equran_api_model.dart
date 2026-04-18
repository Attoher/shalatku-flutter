// Models for EQuran.id API responses

class ProvinceResponse {
  final int code;
  final String message;
  final List<String> data;

  ProvinceResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ProvinceResponse.fromJson(Map<String, dynamic> json) {
    return ProvinceResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: List<String>.from(json['data'] as List),
    );
  }
}

class CityResponse {
  final int code;
  final String message;
  final List<String> data;

  CityResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: List<String>.from(json['data'] as List),
    );
  }
}

class PrayerScheduleResponse {
  final int code;
  final String message;
  final PrayerScheduleData data;

  PrayerScheduleResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory PrayerScheduleResponse.fromJson(Map<String, dynamic> json) {
    return PrayerScheduleResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: PrayerScheduleData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class PrayerScheduleData {
  final String provinsi;
  final String kabkota;
  final int bulan;
  final int tahun;
  final String bulanNama;
  final List<DailyPrayerSchedule> jadwal;

  PrayerScheduleData({
    required this.provinsi,
    required this.kabkota,
    required this.bulan,
    required this.tahun,
    required this.bulanNama,
    required this.jadwal,
  });

  factory PrayerScheduleData.fromJson(Map<String, dynamic> json) {
    var jadwalList = (json['jadwal'] as List)
        .map((item) => DailyPrayerSchedule.fromJson(item as Map<String, dynamic>))
        .toList();

    return PrayerScheduleData(
      provinsi: json['provinsi'] as String,
      kabkota: json['kabkota'] as String,
      bulan: json['bulan'] as int,
      tahun: json['tahun'] as int,
      bulanNama: json['bulan_nama'] as String,
      jadwal: jadwalList,
    );
  }
}

class DailyPrayerSchedule {
  final int tanggal;
  final String tanggalLengkap;
  final String hari;
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  DailyPrayerSchedule({
    required this.tanggal,
    required this.tanggalLengkap,
    required this.hari,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  factory DailyPrayerSchedule.fromJson(Map<String, dynamic> json) {
    return DailyPrayerSchedule(
      tanggal: json['tanggal'] as int,
      tanggalLengkap: json['tanggal_lengkap'] as String,
      hari: json['hari'] as String,
      imsak: json['imsak'] as String,
      subuh: json['subuh'] as String,
      terbit: json['terbit'] as String,
      dhuha: json['dhuha'] as String,
      dzuhur: json['dzuhur'] as String,
      ashar: json['ashar'] as String,
      maghrib: json['maghrib'] as String,
      isya: json['isya'] as String,
    );
  }
}
