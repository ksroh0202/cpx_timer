import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/timer_constants.dart';
import '../../core/enums/exam_stage.dart';
import '../../core/enums/timer_phase.dart';
import '../../models/timer_session_state.dart';
import '../../utils/formatters.dart';
import 'circle_control_button.dart';
import 'pill_button.dart';
import 'rounded_input.dart';
import 'stage_button.dart';

class TimerDisplayCard extends StatelessWidget {
  const TimerDisplayCard({
    super.key,
    required this.state,
    required this.examNameController,
    required this.selectedSubject,
    required this.selectedTopic,
    required this.onSubjectTap,
    required this.onTopicTap,
    required this.onStageSelected,
    required this.primaryAction,
    required this.primaryIcon,
    required this.onReset,
    required this.onStop,
    required this.canReset,
    required this.canStop,
  });

  final TimerSessionState state;
  final TextEditingController examNameController;
  final String selectedSubject;
  final String selectedTopic;
  final VoidCallback onSubjectTap;
  final VoidCallback onTopicTap;
  final ValueChanged<int> onStageSelected;
  final VoidCallback? primaryAction;
  final IconData primaryIcon;
  final VoidCallback onReset;
  final VoidCallback onStop;
  final bool canReset;
  final bool canStop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 360;
        final timerFontSize = math.min(width * 0.28, 110.0);
        final sectionGap = compact ? 14.0 : 18.0;
        final stageGap = compact ? 6.0 : 8.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RoundedInput(
              controller: examNameController,
              hintText: '연습 이름',
            ),
            SizedBox(height: sectionGap),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: selectedSubject,
                    onTap: onSubjectTap,
                  ),
                ),
                SizedBox(width: compact ? 8 : 10),
                Expanded(
                  child: PillButton(
                    label: selectedTopic,
                    onTap: onTopicTap,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 28 : 36),
            SizedBox(
              height: compact ? 108 : 124,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _mainTimeText,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: timerFontSize,
                      fontWeight: FontWeight.w300,
                      height: 0.92,
                      letterSpacing: -3.8,
                      color: const Color(0xFF2F3A44),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 24 : 28),
            Row(
              children: List.generate(ExamStage.values.length, (index) {
                final stage = ExamStage.values[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == ExamStage.values.length - 1 ? 0 : stageGap,
                    ),
                    child: StageButton(
                      label: stage.label,
                      selected: state.currentStage == stage,
                      enabled: state.isExamActive,
                      onTap: () => onStageSelected(index),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: compact ? 28 : 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleControlButton(
                  icon: primaryIcon,
                  onTap: primaryAction,
                  enabled: primaryAction != null,
                ),
                const SizedBox(width: 22),
                CircleControlButton(
                  icon: Icons.refresh_rounded,
                  onTap: canReset ? onReset : null,
                  enabled: canReset,
                ),
                const SizedBox(width: 22),
                CircleControlButton(
                  icon: Icons.stop_rounded,
                  onTap: canStop ? onStop : null,
                  enabled: canStop,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String get _mainTimeText {
    if (state.phase == TimerPhase.prep || state.phase == TimerPhase.pausedPrep) {
      return formatSeconds(state.prepRemaining);
    }

    if (state.phase == TimerPhase.idle) {
      return formatSeconds(TimerConstants.examTotalSeconds);
    }

    return formatSeconds(state.examRemaining);
  }
}
