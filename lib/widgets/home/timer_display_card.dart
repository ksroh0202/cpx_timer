import 'package:flutter/material.dart';

import '../../core/constants/exam_options.dart';
import '../../core/constants/timer_constants.dart';
import '../../core/enums/exam_stage.dart';
import '../../core/enums/timer_phase.dart';
import '../../models/timer_session_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../glass_widgets.dart';

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
  final bool hasSelectedSubject;
  final bool hasSelectedTopic;
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

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompactHeaderFields(
            examNameController: examNameController,
            hintText: defaultExamName,
            selectedSubject: hasSelectedSubject ? selectedSubject : '과목 선택',
            selectedTopic: hasSelectedTopic ? selectedTopic : '주제 선택',
            onSubjectTap: onSubjectTap,
            onTopicTap: onTopicTap,
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              mainTimeText,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 60,
                    height: 0.92,
                    letterSpacing: -3,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryText),
              backgroundColor: AppColors.glassSurfaceSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _StageTextSelector(
            currentStage: state.currentStage,
            enabled: state.isExamActive,
            onStageSelected: onStageSelected,
          ),
          const SizedBox(height: 10),
          _InlineControlPanel(
            primaryAction: primaryAction,
            primaryIcon: primaryIcon,
            onReset: onReset,
            onStop: onStop,
            canReset: canReset,
            canStop: canStop,
          ),
        ],
      ),
    );
  }
}

class _InlineControlPanel extends StatelessWidget {
  const _InlineControlPanel({
    required this.primaryAction,
    required this.primaryIcon,
    required this.onReset,
    required this.onStop,
    required this.canReset,
    required this.canStop,
  });

  final VoidCallback? primaryAction;
  final IconData primaryIcon;
  final VoidCallback onReset;
  final VoidCallback onStop;
  final bool canReset;
  final bool canStop;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: 76,
      padding: const EdgeInsets.all(8),
      surfaceColor: AppColors.glassSurfaceSecondary,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GlassButton(
              icon: primaryIcon,
              onPressed: primaryAction,
              height: 52,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: GlassButton(
              icon: Icons.refresh_rounded,
              onPressed: canReset ? onReset : null,
              height: 52,
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: GlassButton(
              icon: Icons.stop_rounded,
              onPressed: canStop ? onStop : null,
              height: 52,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHeaderFields extends StatelessWidget {
  const _CompactHeaderFields({
    required this.examNameController,
    required this.hintText,
    required this.selectedSubject,
    required this.selectedTopic,
    required this.onSubjectTap,
    required this.onTopicTap,
  });

  final TextEditingController examNameController;
  final String hintText;
  final String selectedSubject;
  final String selectedTopic;
  final VoidCallback onSubjectTap;
  final VoidCallback onTopicTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useCompactStack = constraints.maxWidth < 380;

        if (useCompactStack) {
          return Column(
            children: [
              _GlassTextField(
                controller: examNameController,
                hintText: hintText,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _GlassMetaPicker(
                      value: selectedSubject,
                      onTap: onSubjectTap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GlassMetaPicker(
                      value: selectedTopic,
                      onTap: onTopicTap,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              flex: 5,
              child: _GlassTextField(
                controller: examNameController,
                hintText: hintText,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _GlassMetaPicker(
                value: selectedSubject,
                onTap: onSubjectTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _GlassMetaPicker(
                value: selectedTopic,
                onTap: onTopicTap,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 14,
      minHeight: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      surfaceColor: AppColors.glassSurfaceSecondary,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: '연습 이름',
          labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _GlassMetaPicker extends StatelessWidget {
  const _GlassMetaPicker({
    required this.value,
    required this.onTap,
  });

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: GlassContainer(
          borderRadius: 14,
          minHeight: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          surfaceColor: AppColors.glassSurfaceSecondary,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageTextSelector extends StatelessWidget {
  const _StageTextSelector({
    required this.currentStage,
    required this.enabled,
    required this.onStageSelected,
  });

  final ExamStage? currentStage;
  final bool enabled;
  final ValueChanged<int> onStageSelected;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.72,
      child: IgnorePointer(
        ignoring: !enabled,
        child: GlassSegmentedControl(
          height: 58,
          labels: ExamStage.values.map((stage) => stage.label).toList(),
          selectedIndex: currentStage == null
              ? 0
              : ExamStage.values.indexOf(currentStage!),
          onChanged: onStageSelected,
        ),
      ),
    );
  }
}
