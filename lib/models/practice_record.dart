import '../core/constants/exam_options.dart';

class PracticeRecord {
  final String id;
  final String examName;
  final String subject;
  final String topic;
  final DateTime endedAt;
  final int totalSeconds;
  final int historySeconds;
  final int physicalSeconds;
  final int educationSeconds;
  final String endType;

  const PracticeRecord({
    required this.id,
    required this.examName,
    required this.subject,
    required this.topic,
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
      'examName': examName,
      'subject': subject,
      'topic': topic,
      'endedAt': endedAt.toIso8601String(),
      'totalSeconds': totalSeconds,
      'historySeconds': historySeconds,
      'physicalSeconds': physicalSeconds,
      'educationSeconds': educationSeconds,
      'endType': endType,
    };
  }

  factory PracticeRecord.fromMap(Map<String, dynamic> map) {
    final endedAt =
        DateTime.tryParse(map['endedAt']?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final examName = sanitizeExamName(map['examName']?.toString());
    final subject = sanitizeSubject(map['subject']?.toString());
    final topic = sanitizeTopicForSubject(subject, map['topic']?.toString());
    final totalSeconds = _readInt(map['totalSeconds']);
    final historySeconds = _readInt(map['historySeconds']);
    final physicalSeconds = _readInt(map['physicalSeconds']);
    final educationSeconds = _readInt(map['educationSeconds']);
    final endType = map['endType']?.toString() ?? '정상 종료';
    final id = _readId(
      map['id'],
      endedAt: endedAt,
      totalSeconds: totalSeconds,
      historySeconds: historySeconds,
      physicalSeconds: physicalSeconds,
      educationSeconds: educationSeconds,
      endType: endType,
      examName: examName,
      subject: subject,
      topic: topic,
    );

    return PracticeRecord(
      id: id,
      examName: examName,
      subject: subject,
      topic: topic,
      endedAt: endedAt,
      totalSeconds: totalSeconds,
      historySeconds: historySeconds,
      physicalSeconds: physicalSeconds,
      educationSeconds: educationSeconds,
      endType: endType,
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _readId(
  dynamic rawId, {
  required DateTime endedAt,
  required int totalSeconds,
  required int historySeconds,
  required int physicalSeconds,
  required int educationSeconds,
  required String endType,
  required String examName,
  required String subject,
  required String topic,
}) {
  final id = rawId?.toString().trim() ?? '';
  if (id.isNotEmpty) {
    return id;
  }

  return [
    endedAt.toIso8601String(),
    totalSeconds,
    historySeconds,
    physicalSeconds,
    educationSeconds,
    endType,
    examName,
    subject,
    topic,
  ].join('|');
}
