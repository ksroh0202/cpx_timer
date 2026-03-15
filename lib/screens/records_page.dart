import 'package:flutter/material.dart';

import '../models/practice_record.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../utils/formatters.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({
    super.key,
    required this.records,
    required this.onOpenRecord,
    required this.onDeleteRecord,
    required this.onClearAll,
  });

  final List<PracticeRecord> records;
  final ValueChanged<PracticeRecord> onOpenRecord;
  final ValueChanged<PracticeRecord> onDeleteRecord;
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
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.secondaryText,
                  ),
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Card(
                      elevation: 0,
                      color: AppColors.glassSurface,
                      margin: EdgeInsets.zero,
                      surfaceTintColor: AppColors.transparent,
                      shadowColor: AppColors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppStyles.cardRadius,
                        side: BorderSide(color: AppColors.borderLight, width: 1),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(
                          16,
                          12,
                          8,
                          12,
                        ),
                        title: Text(
                          record.examName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${record.subject} · ${record.topic}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${formatDateTime(record.endedAt)} · ${formatSeconds(record.totalSeconds)} · ${record.endType}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.secondaryText,
                          ),
                          tooltip: '기록 삭제',
                          onPressed: () => onDeleteRecord(record),
                        ),
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
