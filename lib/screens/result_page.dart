import 'package:flutter/material.dart';

import '../widgets/stage_row.dart';
import '../models/practice_record.dart';
import '../utils/formatters.dart';
import '../utils/formatters.dart';

class ResultPage extends StatelessWidget {
  final PracticeRecord record;

  const ResultPage({super.key, required this.record});

  String formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결과 상세'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    '연습 결과',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    formatSeconds(record.totalSeconds),
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    record.endType,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDateTime(record.endedAt),
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  StageRow(
                    label: '병력 청취',
                    value: formatSeconds(record.historySeconds),
                  ),
                  const Divider(height: 20),
                  StageRow(
                    label: '신체 진찰',
                    value: formatSeconds(record.physicalSeconds),
                  ),
                  const Divider(height: 20),
                  StageRow(
                    label: '환자 교육',
                    value: formatSeconds(record.educationSeconds),
                  ),
                  const Divider(height: 20),
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