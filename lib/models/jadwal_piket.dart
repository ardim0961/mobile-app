import 'dart:convert';

class JadwalPiket {
  final String id;
  final String kodePetugas;
  final String namaPetugas;
  final String hariPiket;
  final String shift;
  final String tugas;
  final String jamPiket;
  String statusPiket;
  final String? imagePath;
  String? buktiPiketPath;

  JadwalPiket({
    required this.id,
    required this.kodePetugas,
    required this.namaPetugas,
    required this.hariPiket,
    required this.shift,
    required this.tugas,
    required this.jamPiket,
    this.statusPiket = 'Belum Piket',
    this.imagePath,
    this.buktiPiketPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kodePetugas': kodePetugas,
      'namaPetugas': namaPetugas,
      'hariPiket': hariPiket,
      'shift': shift,
      'tugas': tugas,
      'jamPiket': jamPiket,
      'statusPiket': statusPiket,
      'imagePath': imagePath,
      'buktiPiketPath': buktiPiketPath,
    };
  }

  factory JadwalPiket.fromMap(Map<String, dynamic> map) {
    return JadwalPiket(
      id: map['id'] ?? '',
      kodePetugas: map['kodePetugas'] ?? '',
      namaPetugas: map['namaPetugas'] ?? '',
      hariPiket: map['hariPiket'] ?? '',
      shift: map['shift'] ?? '',
      tugas: map['tugas'] ?? '',
      jamPiket: map['jamPiket'] ?? '',
      statusPiket: map['statusPiket'] ?? 'Belum Piket',
      imagePath: map['imagePath'],
      buktiPiketPath: map['buktiPiketPath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory JadwalPiket.fromJson(String source) => JadwalPiket.fromMap(json.decode(source));

  static List<String> get daftarHari => [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  static List<String> get daftarShift => ['Pagi', 'Siang', 'Sore'];

  static List<String> get daftarTugas => ['Sapu', 'Pel', 'Buang Sampah'];

  static Map<String, String> get jamPerShift => {
    'Pagi': '07:00',
    'Siang': '12:00',
    'Sore': '16:00',
  };
}
