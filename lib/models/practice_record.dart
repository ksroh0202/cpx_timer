// 한 번의 연습 결과를 저장하기 위한 데이터 묶음입니다.
class PracticeRecord {
  final String id;
  final DateTime endedAt;
  final int totalSeconds;
  final int historySeconds;
  final int physicalSeconds;
  final int educationSeconds;
  final String endType;

  const PracticeRecord({
    required this.id,
    required this.endedAt,
    required this.totalSeconds,
    required this.historySeconds,
    required this.physicalSeconds,
    required this.educationSeconds,
    required this.endType,
  });

  // 객체를 저장하기 쉬운 Map 형태로 바꿉니다.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'endedAt': endedAt.toIso8601String(),
      'totalSeconds': totalSeconds,
      'historySeconds': historySeconds,
      'physicalSeconds': physicalSeconds,
      'educationSeconds': educationSeconds,
      'endType': endType,
    };
  }

  // 저장된 Map 데이터를 다시 PracticeRecord 객체로 복원합니다.
  factory PracticeRecord.fromMap(Map<String, dynamic> map) {
    return PracticeRecord(
      id: map['id'],
      endedAt: DateTime.parse(map['endedAt']),
      totalSeconds: map['totalSeconds'],
      historySeconds: map['historySeconds'],
      physicalSeconds: map['physicalSeconds'],
      educationSeconds: map['educationSeconds'],
      endType: map['endType'],
    );
  }
}
