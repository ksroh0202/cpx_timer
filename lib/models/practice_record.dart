import '../core/constants/exam_options.dart';
import '../core/constants/timer_constants.dart';

const String finishTypeEarly = 'early';
const String finishTypeOvertime = 'overtime';

class PracticeRecord {
  const PracticeRecord({
    required this.id,
    required this.examName,
    required this.subject,
    required this.topic,
    required this.date,
    required this.plannedDurationSec,
    required this.actualEndSec,
    required this.finishType,
    required this.historySeconds,
    required this.physicalSeconds,
    required this.educationSeconds,
  });

  final String id;
  final String examName;
  final String subject;
  final String topic;
  final DateTime date;
  final int plannedDurationSec;
  final int actualEndSec;
  final String finishType;
  final int historySeconds;
  final int physicalSeconds;
  final int educationSeconds;

  DateTime get endedAt => date;
  int get totalSeconds => actualEndSec;
  String get endType => finishType;

  bool get isEarlyFinish => finishType == finishTypeEarly;
  bool get isOvertimeFinish => finishType == finishTypeOvertime;

  PracticeRecord copyWith({
    String? examName,
    String? subject,
    String? topic,
  }) {
    final nextSubject = sanitizeSubject(subject ?? this.subject);
    return PracticeRecord(
      id: id,
      examName: sanitizeExamName(examName ?? this.examName),
      subject: nextSubject,
      topic: sanitizeTopicForSubject(nextSubject, topic ?? this.topic),
      date: date,
      plannedDurationSec: plannedDurationSec,
      actualEndSec: actualEndSec,
      finishType: finishType,
      historySeconds: historySeconds,
      physicalSeconds: physicalSeconds,
      educationSeconds: educationSeconds,
    );
  }

  String get finishTypeLabel {
    switch (finishType) {
      case finishTypeEarly:
        return '조기 종료';
      case finishTypeOvertime:
        return '시간 초과';
      default:
        return finishType;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examName': examName,
      'subject': subject,
      'topic': topic,
      'date': date.toIso8601String(),
      'plannedDurationSec': plannedDurationSec,
      'actualEndSec': actualEndSec,
      'finishType': finishType,
      'historySeconds': historySeconds,
      'physicalSeconds': physicalSeconds,
      'educationSeconds': educationSeconds,
    };
  }

  factory PracticeRecord.fromMap(Map<String, dynamic> map) {
    final subject = sanitizeSubject(map['subject']?.toString());
    final topic = sanitizeTopicForSubject(subject, map['topic']?.toString());
    final plannedDurationSec =
        _readInt(map['plannedDurationSec']) > 0
            ? _readInt(map['plannedDurationSec'])
            : TimerConstants.examTotalSeconds;
    final actualEndSec = _readActualEndSec(map, plannedDurationSec);
    final finishType = _normalizeFinishType(
      rawValue: map['finishType']?.toString() ?? map['endType']?.toString(),
      actualEndSec: actualEndSec,
      plannedDurationSec: plannedDurationSec,
    );
    final date = _readDate(map);
    final examName = sanitizeExamName(map['examName']?.toString());
    final historySeconds = _readInt(map['historySeconds']);
    final physicalSeconds = _readInt(map['physicalSeconds']);
    final educationSeconds = _readInt(map['educationSeconds']);

    return PracticeRecord(
      id: _readId(
        map['id'],
        date: date,
        subject: subject,
        topic: topic,
        actualEndSec: actualEndSec,
        finishType: finishType,
      ),
      examName: examName,
      subject: subject,
      topic: topic,
      date: date,
      plannedDurationSec: plannedDurationSec,
      actualEndSec: actualEndSec,
      finishType: finishType,
      historySeconds: historySeconds,
      physicalSeconds: physicalSeconds,
      educationSeconds: educationSeconds,
    );
  }
}

DateTime _readDate(Map<String, dynamic> map) {
  return DateTime.tryParse(
        map['date']?.toString() ?? map['endedAt']?.toString() ?? '',
      ) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

int _readActualEndSec(Map<String, dynamic> map, int plannedDurationSec) {
  final rawActualEndSec = _readInt(map['actualEndSec']);
  if (rawActualEndSec > 0) {
    return rawActualEndSec;
  }

  final legacyTotalSeconds = _readInt(map['totalSeconds']);
  if (legacyTotalSeconds > 0) {
    return legacyTotalSeconds;
  }

  return plannedDurationSec;
}

String _normalizeFinishType({
  required String? rawValue,
  required int actualEndSec,
  required int plannedDurationSec,
}) {
  final value = rawValue?.trim().toLowerCase() ?? '';
  if (value == finishTypeEarly || value == '조기 종료') {
    return finishTypeEarly;
  }
  if (value == finishTypeOvertime ||
      value == '정상 종료' ||
      value == 'normal' ||
      value == '시간 초과') {
    return finishTypeOvertime;
  }
  return actualEndSec < plannedDurationSec
      ? finishTypeEarly
      : finishTypeOvertime;
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _readId(
  dynamic rawId, {
  required DateTime date,
  required String subject,
  required String topic,
  required int actualEndSec,
  required String finishType,
}) {
  final id = rawId?.toString().trim() ?? '';
  if (id.isNotEmpty) {
    return id;
  }

  return [
    date.toIso8601String(),
    subject,
    topic,
    actualEndSec,
    finishType,
  ].join('|');
}
