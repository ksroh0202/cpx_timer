// 단계별 누적 시간과 총 사용 시간을 카드 형태로 보여준다.
import 'package:flutter/material.dart';

import '../../core/enums/exam_stage.dart';
import '../../models/timer_session_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/formatters.dart';
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
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '단계별 누적 시간',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          StageRow(
            label: ExamStage.historyTaking.label,
            value: formatSeconds(previewStageSeconds(ExamStage.historyTaking)),
          ),
          const Divider(color: AppColors.line, height: 1),
          StageRow(
            label: ExamStage.physicalExam.label,
            value: formatSeconds(previewStageSeconds(ExamStage.physicalExam)),
          ),
          const Divider(color: AppColors.line, height: 1),
          StageRow(
            label: ExamStage.patientEducation.label,
            value: formatSeconds(previewStageSeconds(ExamStage.patientEducation)),
          ),
          const Divider(color: AppColors.line, height: 1),
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
