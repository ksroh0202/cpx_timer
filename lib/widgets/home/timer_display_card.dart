// 메인 타이머 숫자, 상태 문구, 진행률, 단계 선택 UI를 표시한다.
import 'package:flutter/material.dart';

import '../../core/constants/timer_constants.dart';
import '../../core/enums/exam_stage.dart';
import '../../core/enums/timer_phase.dart';
import '../../models/timer_session_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';
import '../../utils/formatters.dart';
import 'stage_selector.dart';

class TimerDisplayCard extends StatelessWidget {
  const TimerDisplayCard({
    super.key,
    required this.state,
    required this.onStageSelected,
  });

  final TimerSessionState state;
  final ValueChanged<int> onStageSelected;

  @override
  Widget build(BuildContext context) {
    final progress =
        state.phase == TimerPhase.prep || state.phase == TimerPhase.pausedPrep
            ? 1 - (state.prepRemaining / TimerConstants.prepTotalSeconds)
            : 1 - (state.examRemaining / TimerConstants.examTotalSeconds);

    final mainTimeText =
        state.phase == TimerPhase.prep || state.phase == TimerPhase.pausedPrep
            ? formatSeconds(state.prepRemaining)
            : formatSeconds(state.phase == TimerPhase.idle
                ? TimerConstants.examTotalSeconds
                : state.examRemaining);

    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              mainTimeText,
              style: AppStyles.timerText,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              state.currentStage?.label ?? state.statusText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 18,
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: AppStyles.pillRadius,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 18),
          StageSelector(
            currentStage: state.currentStage,
            enabled: state.isExamActive,
            onStageSelected: onStageSelected,
          ),
        ],
      ),
    );
  }
}
