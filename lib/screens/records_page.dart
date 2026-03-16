import 'package:flutter/material.dart';

import '../models/practice_record.dart';
import '../utils/formatters.dart';
import '../widgets/home/glass_card.dart';
import '../widgets/home/pill_button.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SizedBox(
                height: constraints.maxHeight - 14,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '기록',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2F3A44),
                              ),
                            ),
                          ),
                          if (records.isNotEmpty)
                            SizedBox(
                              width: 104,
                              child: PillButton(
                                label: '전체 삭제',
                                onTap: onClearAll,
                                height: 40,
                                fontSize: 14,
                                horizontalPadding: 10,
                                textColor: const Color(0xFF6B7684),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: records.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3E8EE),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '아직 저장된 기록이 없습니다.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6E7986),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 2),
                                itemCount: records.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final record = records[index];
                                  return _RecordTile(
                                    record: record,
                                    onOpenRecord: onOpenRecord,
                                    onDeleteRecord: onDeleteRecord,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.onOpenRecord,
    required this.onDeleteRecord,
  });

  final PracticeRecord record;
  final ValueChanged<PracticeRecord> onOpenRecord;
  final ValueChanged<PracticeRecord> onDeleteRecord;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE3E8EE),
      borderRadius: BorderRadius.circular(20),
      shadowColor: const Color(0x00000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onOpenRecord(record),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.examName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2F3A44),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.subject} / ${record.topic}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5F6B78),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDateTime(record.endedAt)} / ${formatSeconds(record.totalSeconds)} / ${record.endType}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7E8894),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onDeleteRecord(record),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF7E8894),
                ),
                tooltip: '기록 삭제',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
