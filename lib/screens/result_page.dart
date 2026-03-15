import 'package:flutter/material.dart';

import '../models/practice_record.dart';
import '../utils/formatters.dart';
import '../widgets/stage_row.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.record});

  final PracticeRecord record;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('결과 상세')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    record.examName,
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${record.subject} · ${record.topic}',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    formatSeconds(record.totalSeconds),
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    record.endType,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatDateTime(record.endedAt),
                    style: textTheme.bodyMedium?.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StageRow(
                    label: '병력 청취',
                    value: formatSeconds(record.historySeconds),
                  ),
                  const Divider(height: 1),
                  StageRow(
                    label: '신체 진찰',
                    value: formatSeconds(record.physicalSeconds),
                  ),
                  const Divider(height: 1),
                  StageRow(
                    label: '환자 교육',
                    value: formatSeconds(record.educationSeconds),
                  ),
                  const Divider(height: 1),
                  StageRow(
                    label: '총 사용 시간',
                    value: formatSeconds(record.totalSeconds),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
