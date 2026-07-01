import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jadwal_piket.dart';

class PiketStorage {
  static const String _keyPiket = 'piket_data';

  static Future<void> savePiketList(List<JadwalPiket> list) async {
    final pref = await SharedPreferences.getInstance();
    List<String> jsonList = list.map((item) => item.toJson()).toList();
    await pref.setStringList(_keyPiket, jsonList);
  }

  static Future<List<JadwalPiket>> loadPiketList() async {
    final pref = await SharedPreferences.getInstance();
    List<String>? jsonList = pref.getStringList(_keyPiket);
    
    if (jsonList == null || jsonList.isEmpty) {
      return [];
    }

    return jsonList.map((item) => JadwalPiket.fromJson(item)).toList();
  }
}
