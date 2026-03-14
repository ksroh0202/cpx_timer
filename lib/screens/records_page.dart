// 저장된 연습 기록 목록을 보여주고 상세 화면 진입을 처리한다.
import 'package:flutter/material.dart';

import '../models/practice_record.dart';
import '../theme/app_styles.dart';
import '../utils/formatters.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({
    super.key,
    required this.records,
    required this.onOpenRecord,
    required this.onClearAll,
  });

  final List<PracticeRecord> records;
  final ValueChanged<PracticeRecord> onOpenRecord;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (records.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onClearAll,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('전체 삭제'),
                ),
              ],
            ),
          ),
        Expanded(
          child: records.isEmpty
              ? Center(
                  child: Text(
                    '아직 저장된 기록이 없습니다.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppStyles.cardRadius,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          formatDateTime(record.endedAt),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${record.endType}  ·  ${formatSeconds(record.totalSeconds)}',
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => onOpenRecord(record),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
