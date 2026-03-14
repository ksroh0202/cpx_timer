// SharedPreferences 기반으로 연습 기록을 저장하고 불러온다.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_record.dart';

// 연습 기록을 로컬 저장소에 저장하고 불러오는 전용 클래스입니다.
class RecordStorage {
  static const String prefsKey = 'cpx_records';

  // 저장된 문자열 목록을 읽어서 PracticeRecord 목록으로 변환합니다.
  static Future<List<PracticeRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();

    final rawList = prefs.getStringList(prefsKey) ?? [];

    // 최신 기록이 위로 오도록 최근 날짜 순으로 정렬합니다.
    final parsed = rawList
        .map((e) => PracticeRecord.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.endedAt.compareTo(a.endedAt));

    return parsed;
  }

  // 현재 기록 목록 전체를 문자열로 바꿔 저장합니다.
  static Future<void> saveRecords(List<PracticeRecord> records) async {
    final prefs = await SharedPreferences.getInstance();

    final rawList =
        records.map((e) => jsonEncode(e.toMap())).toList();

    await prefs.setStringList(prefsKey, rawList);
  }
}
