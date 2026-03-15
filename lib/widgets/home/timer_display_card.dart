import 'package:flutter/material.dart';

import '../../core/constants/exam_options.dart';
import '../../core/constants/timer_constants.dart';
import '../../core/enums/timer_phase.dart';
import '../../models/timer_session_state.dart';
import '../../theme/app_spacing.dart';
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
  });

  final TimerSessionState state;
  final TextEditingController examNameController;
  final String selectedSubject;
  final String selectedTopic;
  final bool hasSelectedSubject;
  final bool hasSelectedTopic;
  final VoidCallback onSubjectTap;
  final VoidCallback onTopicTap;

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
      height: 340,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlassTextField(
                controller: examNameController,
                hintText: defaultExamName,
              ),
              const SizedBox(height: AppSpacing.component),
              Row(
                children: [
                  Expanded(
                    child: _GlassMetaPicker(
                      value: hasSelectedSubject ? selectedSubject : '과목 선택',
                      onTap: onSubjectTap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.component),
                  Expanded(
                    child: _GlassMetaPicker(
                      value: hasSelectedTopic ? selectedTopic : '주제 선택',
                      onTap: onTopicTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Text(
                mainTimeText,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 64,
                      height: 0.92,
                      letterSpacing: -3,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: AppSpacing.component + 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.black87),
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                ),
              ),
            ],
          ),
        ],
      ),
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
      borderRadius: 22,
      minHeight: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: '연습 이름',
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: GlassContainer(
          borderRadius: 22,
          minHeight: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
