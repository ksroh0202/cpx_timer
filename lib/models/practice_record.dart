

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
