import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_record.dart';

class RecordStorage {
  static const String prefsKey = 'cpx_records';

  static Future<List<PracticeRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();

    final rawList = prefs.getStringList(prefsKey) ?? [];

    final parsed = rawList
        .map((e) => PracticeRecord.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.endedAt.compareTo(a.endedAt));

    return parsed;
  }

  static Future<void> saveRecords(List<PracticeRecord> records) async {
    final prefs = await SharedPreferences.getInstance();

    final rawList =
        records.map((e) => jsonEncode(e.toMap())).toList();

    await prefs.setStringList(prefsKey, rawList);
  }
}