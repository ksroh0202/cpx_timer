import 'package:flutter/material.dart';

import '../models/practice_record.dart';
import '../utils/formatters.dart';
import '../widgets/stage_row.dart';

// 한 번 끝난 연습의 상세 결과를 보여 주는 화면입니다.
class ResultPage extends StatelessWidget {
  final PracticeRecord record;

  const ResultPage({super.key, required this.record});

  // 날짜와 시간을 읽기 쉬운 문자열로 바꿉니다.
  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 위 카드는 전체 결과, 아래 카드는 단계별 시간을 보여 줍니다.
    return Scaffold(
      appBar: AppBar(
        title: const Text('결과 상세'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('연습 결과', style: textTheme.titleLarge),
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
                    _formatDateTime(record.endedAt),
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
