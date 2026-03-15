import 'package:flutter/material.dart';

import '../../core/enums/exam_stage.dart';
import '../../models/timer_session_state.dart';
import '../../utils/formatters.dart';
import '../glass_widgets.dart';
import '../stage_row.dart';

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
    return GlassContainer(
      height: 196,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StageRow(
            label: ExamStage.historyTaking.label,
            value: formatSeconds(previewStageSeconds(ExamStage.historyTaking)),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.26)),
          StageRow(
            label: ExamStage.physicalExam.label,
            value: formatSeconds(previewStageSeconds(ExamStage.physicalExam)),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.26)),
          StageRow(
            label: ExamStage.patientEducation.label,
            value: formatSeconds(previewStageSeconds(ExamStage.patientEducation)),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.26)),
          StageRow(
            label: '총 사용 시간',
            value: formatSeconds(state.examElapsed),
            isBold: true,
          ),
        ],
      ),
    );
  }
}
