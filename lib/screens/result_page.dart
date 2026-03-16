import 'package:flutter/material.dart';

import '../models/practice_record.dart';
import '../utils/formatters.dart';
import '../widgets/home/glass_card.dart';
import '../widgets/home/stats_card.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.record});

  final PracticeRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6EEF5),
      appBar: AppBar(
        title: const Text(
          '결과 상세',
          style: TextStyle(
            color: Color(0xFF2F3A44),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF2F3A44),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6EEF5),
              Color(0xFFDCE6EE),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 760;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  10,
                  compact ? 8 : 14,
                  10,
                  compact ? 20 : 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SizedBox(
                        width: double.infinity,
                        height: constraints.maxHeight,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SummarySection(record: record),
                              SizedBox(height: compact ? 14 : 18),
                              StatsCard(
                                rows: [
                                  (
                                    label: '병력 청취',
                                    value: formatSeconds(record.historySeconds),
                                  ),
                                  (
                                    label: '신체 진찰',
                                    value: formatSeconds(record.physicalSeconds),
                                  ),
                                  (
                                    label: '환자 교육',
                                    value: formatSeconds(record.educationSeconds),
                                  ),
                                ],
                                totalLabel: '총 사용 시간',
                                totalValue: formatSeconds(record.totalSeconds),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.record});

  final PracticeRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8EE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            record.examName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F3A44),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${record.subject} / ${record.topic}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6A7481),
            ),
          ),
          const SizedBox(height: 22),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatSeconds(record.totalSeconds),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w300,
                height: 0.92,
                letterSpacing: -3.0,
                color: Color(0xFF2F3A44),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            record.endType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2F3A44),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatDateTime(record.endedAt),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7A8591),
            ),
          ),
        ],
      ),
    );
  }
}
