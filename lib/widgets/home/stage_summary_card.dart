import 'package:flutter/material.dart';

import '../../core/enums/exam_stage.dart';
import '../../models/timer_session_state.dart';
import '../../utils/formatters.dart';
import 'stats_card.dart';

class StageSummaryCard extends StatelessWidget {
  const StageSummaryCard({
    super.key,
    required this.state,
    required this.previewStageSeconds,
  });

  final TimerSessionState state;
  final int Function(ExamStage stage) previewStageSeconds;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      rows: [
        (
          label: ExamStage.historyTaking.label,
          value: formatSeconds(previewStageSeconds(ExamStage.historyTaking)),
        ),
        (
          label: ExamStage.physicalExam.label,
          value: formatSeconds(previewStageSeconds(ExamStage.physicalExam)),
        ),
        (
          label: ExamStage.patientEducation.label,
          value: formatSeconds(previewStageSeconds(ExamStage.patientEducation)),
        ),
      ],
      totalLabel: '총 사용 시간',
      totalValue: formatSeconds(state.examElapsed),
    );
  }
}
