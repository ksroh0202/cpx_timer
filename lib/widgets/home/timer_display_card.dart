import 'package:flutter/material.dart';

import '../../core/constants/exam_options.dart';
import '../../core/constants/timer_constants.dart';
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
    required this.examNameController,
    required this.selectedSubject,
    required this.selectedTopic,
    required this.hasSelectedSubject,
    required this.hasSelectedTopic,
    required this.onSubjectTap,
    required this.onTopicTap,
    required this.onStageSelected,
  });

  final TimerSessionState state;
  final TextEditingController examNameController;
  final String selectedSubject;
  final String selectedTopic;
  final bool hasSelectedSubject;
  final bool hasSelectedTopic;
  final VoidCallback onSubjectTap;
  final VoidCallback onTopicTap;
  final ValueChanged<int> onStageSelected;

  bool get _showStageSelector {
    return state.phase == TimerPhase.exam || state.phase == TimerPhase.pausedExam;
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        state.phase == TimerPhase.prep || state.phase == TimerPhase.pausedPrep
            ? 1 - (state.prepRemaining / TimerConstants.prepTotalSeconds)
            : 1 - (state.examRemaining / TimerConstants.examTotalSeconds);

    final mainTimeText =
        state.phase == TimerPhase.prep || state.phase == TimerPhase.pausedPrep
            ? formatSeconds(state.prepRemaining)
            : formatSeconds(
                state.phase == TimerPhase.idle
                    ? TimerConstants.examTotalSeconds
                    : state.examRemaining,
              );

    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: examNameController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: defaultExamName,
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceSoft,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: AppStyles.softPillDecoration,
            child: Row(
              children: [
                _PickerButton(
                  label: hasSelectedSubject ? selectedSubject : '시험 과목',
                  onTap: onSubjectTap,
                ),
                const SizedBox(width: 6),
                _PickerButton(
                  label: hasSelectedTopic ? selectedTopic : '시험 주제',
                  onTap: onTopicTap,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              mainTimeText,
              style: AppStyles.timerText,
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
          if (_showStageSelector) ...[
            const SizedBox(height: 18),
            StageSelector(
              currentStage: state.currentStage,
              enabled: state.isExamActive,
              onStageSelected: onStageSelected,
            ),
          ],
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: AppStyles.cardInnerRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppStyles.cardInnerRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: AppColors.iconSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
