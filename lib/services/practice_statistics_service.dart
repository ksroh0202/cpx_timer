import '../models/practice_record.dart';

const String statisticsAllLabel = '\uC804\uCCB4';

enum StatisticsRange {
  all,
  last7Days,
  last14Days,
  last30Days,
}

class StatisticsFilter {
  const StatisticsFilter({
    this.range = StatisticsRange.all,
    this.subject,
    this.topic,
  });

  final StatisticsRange range;
  final String? subject;
  final String? topic;
}

class PracticeStatisticsService {
  static const int trendDisplayCapSec = 120;

  const PracticeStatisticsService._();

  static List<PracticeRecord> filterRecords(
    List<PracticeRecord> records,
    StatisticsFilter filter,
  ) {
    final normalizedSubject = _normalizeFilterValue(filter.subject);
    final normalizedTopic = _normalizeFilterValue(filter.topic);

    return records.where((record) {
      if (!_matchesRange(record, filter.range)) {
        return false;
      }
      if (normalizedSubject != null && record.subject != normalizedSubject) {
        return false;
      }
      if (normalizedTopic != null && record.topic != normalizedTopic) {
        return false;
      }
      return true;
    }).toList();
  }

  static PracticeStatisticsSummary summarize(List<PracticeRecord> records) {
    if (records.isEmpty) {
      return const PracticeStatisticsSummary.empty();
    }

    final totalCount = records.length;
    final overtimeRecords = records.where((record) => record.isOvertimeFinish);
    final earlyRecords = records.where((record) => record.isEarlyFinish);
    final overtimeCount = overtimeRecords.length;
    final earlyCount = earlyRecords.length;
    final weakSubject = _findWeakSubject(records);

    return PracticeStatisticsSummary(
      totalCount: totalCount,
      averageEndSec: _average(records.map((record) => record.actualEndSec)),
      overtimeCount: overtimeCount,
      overtimeRate: _ratio(overtimeCount, totalCount),
      earlyCount: earlyCount,
      earlyRate: _ratio(earlyCount, totalCount),
      averageOvertimeSec: _average(
        overtimeRecords.map(
          (record) => _nonNegative(record.actualEndSec - record.plannedDurationSec),
        ),
      ),
      averageRemainingSec: _average(
        earlyRecords.map(
          (record) => _nonNegative(record.plannedDurationSec - record.actualEndSec),
        ),
      ),
      averageHistorySec: _average(
        records.map((record) => record.historySeconds),
      ),
      averagePhysicalSec: _average(
        records.map((record) => record.physicalSeconds),
      ),
      averageEducationSec: _average(
        records.map((record) => record.educationSeconds),
      ),
      weakSubjectLabel: weakSubject.label,
      weakSubjectRate: weakSubject.rate,
      distribution: [
        DistributionBucket(
          label: '\u0031\uBD84 \uC774\uC0C1 \uC5EC\uC720',
          count: records.where((record) => _deltaFromPlan(record) <= -60).length,
        ),
        DistributionBucket(
          label: '\u0033\u0030~\u0035\u0039\uCD08 \uC5EC\uC720',
          count: records
              .where(
                (record) =>
                    _deltaFromPlan(record) > -60 &&
                    _deltaFromPlan(record) <= -30,
              )
              .length,
        ),
        DistributionBucket(
          label: '\u0033\u0030\uCD08 \uC774\uB0B4',
          count: records
              .where(
                (record) =>
                    _deltaFromPlan(record) > -30 &&
                    _deltaFromPlan(record) <= 30,
              )
              .length,
        ),
        DistributionBucket(
          label: '\u0033\u0030\uCD08 \uC774\uC0C1 \uCD08\uACFC',
          count: records.where((record) => _deltaFromPlan(record) > 30).length,
        ),
      ],
    );
  }

  static TrendChartData buildTrendChartData(List<PracticeRecord> records) {
    final sortedRecords = [...records]
      ..sort((a, b) => a.date.compareTo(b.date));
    final points = sortedRecords
        .map(
          (record) {
            final deltaSec = _deltaFromPlan(record);
            final displayDeltaSec = deltaSec.clamp(
              -trendDisplayCapSec,
              trendDisplayCapSec,
            );
            return TrendBarPoint(
              date: record.date,
              plannedDurationSec: record.plannedDurationSec,
              actualEndSec: record.actualEndSec,
              deltaSec: deltaSec,
              displayDeltaSec: displayDeltaSec,
            );
          },
        )
        .toList();

    return TrendChartData(
      points: points,
      baselineSec: _resolveBaselineSeconds(sortedRecords),
      maxAbsDeltaSec: trendDisplayCapSec,
    );
  }

  static bool _matchesRange(PracticeRecord record, StatisticsRange range) {
    if (range == StatisticsRange.all) {
      return true;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = switch (range) {
      StatisticsRange.all => 0,
      StatisticsRange.last7Days => 7,
      StatisticsRange.last14Days => 14,
      StatisticsRange.last30Days => 30,
    };
    final threshold = today.subtract(Duration(days: days - 1));
    final recordDay = DateTime(
      record.date.year,
      record.date.month,
      record.date.day,
    );
    return !recordDay.isBefore(threshold);
  }

  static String? _normalizeFilterValue(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == statisticsAllLabel) {
      return null;
    }
    return trimmed;
  }

  static int _average(Iterable<int> values) {
    var count = 0;
    var sum = 0;
    for (final value in values) {
      count += 1;
      sum += value;
    }
    if (count == 0) {
      return 0;
    }
    return (sum / count).round();
  }

  static double _ratio(int count, int total) {
    if (total == 0) {
      return 0;
    }
    return (count / total) * 100;
  }

  static int _deltaFromPlan(PracticeRecord record) =>
      record.actualEndSec - record.plannedDurationSec;

  static int _nonNegative(int value) => value < 0 ? 0 : value;

  static int? _resolveBaselineSeconds(List<PracticeRecord> records) {
    if (records.isEmpty) {
      return null;
    }

    final first = records.first.plannedDurationSec;
    final hasSameBaseline = records.every(
      (record) => record.plannedDurationSec == first,
    );
    return hasSameBaseline ? first : null;
  }

  static ({String label, double rate}) _findWeakSubject(
    List<PracticeRecord> records,
  ) {
    final buckets = <String, List<PracticeRecord>>{};
    for (final record in records) {
      buckets.putIfAbsent(record.subject, () => []).add(record);
    }

    var weakSubjectLabel = '-';
    var weakSubjectRate = 0.0;

    for (final entry in buckets.entries) {
      final total = entry.value.length;
      final overtimeCount = entry.value
          .where((record) => record.isOvertimeFinish)
          .length;
      final rate = _ratio(overtimeCount, total);
      if (rate > weakSubjectRate) {
        weakSubjectRate = rate;
        weakSubjectLabel = entry.key;
      }
    }

    return (label: weakSubjectLabel, rate: weakSubjectRate);
  }
}

class PracticeStatisticsSummary {
  const PracticeStatisticsSummary({
    required this.totalCount,
    required this.averageEndSec,
    required this.overtimeCount,
    required this.overtimeRate,
    required this.earlyCount,
    required this.earlyRate,
    required this.averageOvertimeSec,
    required this.averageRemainingSec,
    required this.averageHistorySec,
    required this.averagePhysicalSec,
    required this.averageEducationSec,
    required this.weakSubjectLabel,
    required this.weakSubjectRate,
    required this.distribution,
  });

  const PracticeStatisticsSummary.empty()
    : totalCount = 0,
      averageEndSec = 0,
      overtimeCount = 0,
      overtimeRate = 0,
      earlyCount = 0,
      earlyRate = 0,
      averageOvertimeSec = 0,
      averageRemainingSec = 0,
      averageHistorySec = 0,
      averagePhysicalSec = 0,
      averageEducationSec = 0,
      weakSubjectLabel = '-',
      weakSubjectRate = 0,
      distribution = const [];

  final int totalCount;
  final int averageEndSec;
  final int overtimeCount;
  final double overtimeRate;
  final int earlyCount;
  final double earlyRate;
  final int averageOvertimeSec;
  final int averageRemainingSec;
  final int averageHistorySec;
  final int averagePhysicalSec;
  final int averageEducationSec;
  final String weakSubjectLabel;
  final double weakSubjectRate;
  final List<DistributionBucket> distribution;
}

class DistributionBucket {
  const DistributionBucket({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;
}

class TrendChartData {
  const TrendChartData({
    required this.points,
    required this.baselineSec,
    required this.maxAbsDeltaSec,
  });

  final List<TrendBarPoint> points;
  final int? baselineSec;
  final int maxAbsDeltaSec;
}

class TrendBarPoint {
  const TrendBarPoint({
    required this.date,
    required this.plannedDurationSec,
    required this.actualEndSec,
    required this.deltaSec,
    required this.displayDeltaSec,
  });

  final DateTime date;
  final int plannedDurationSec;
  final int actualEndSec;
  final int deltaSec;
  final int displayDeltaSec;
}
