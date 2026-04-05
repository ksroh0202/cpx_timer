import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/timer_constants.dart';
import '../../core/enums/exam_stage.dart';
import '../../core/enums/timer_phase.dart';
import '../../models/timer_session_state.dart';
import '../../utils/formatters.dart';
import 'circle_control_button.dart';
import 'pill_button.dart';
import 'stage_button.dart';

class TimerDisplayCard extends StatefulWidget {
  const TimerDisplayCard({
    super.key,
    required this.state,
    required this.selectedSubject,
    required this.selectedTopic,
    required this.onSubjectTap,
    required this.onTopicTap,
    required this.onStageSelected,
    required this.primaryAction,
    required this.primaryIcon,
    required this.onReset,
    required this.onStop,
    required this.onDecreaseDuration,
    required this.onIncreaseDuration,
    required this.onDecreaseQuestionCount,
    required this.onIncreaseQuestionCount,
    required this.onDecreaseBreakDuration,
    required this.onIncreaseBreakDuration,
    required this.canAdjustDuration,
    required this.canAdjustContinuousSettings,
    required this.canReset,
    required this.canStop,
  });

  final TimerSessionState state;
  final String selectedSubject;
  final String selectedTopic;
  final VoidCallback onSubjectTap;
  final VoidCallback onTopicTap;
  final ValueChanged<int> onStageSelected;
  final VoidCallback? primaryAction;
  final IconData primaryIcon;
  final VoidCallback onReset;
  final VoidCallback onStop;
  final VoidCallback onDecreaseDuration;
  final VoidCallback onIncreaseDuration;
  final VoidCallback onDecreaseQuestionCount;
  final VoidCallback onIncreaseQuestionCount;
  final VoidCallback onDecreaseBreakDuration;
  final VoidCallback onIncreaseBreakDuration;
  final bool canAdjustDuration;
  final bool canAdjustContinuousSettings;
  final bool canReset;
  final bool canStop;

  @override
  State<TimerDisplayCard> createState() => _TimerDisplayCardState();
}

class _TimerDisplayCardState extends State<TimerDisplayCard> {
  bool _isRepeatSettingsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = width < 360;
        final timerFontSize = math.min(width * 0.28, 110.0);
        final sectionGap = compact ? 24.0 : 28.0;
        final progressGap = compact ? 12.0 : 14.0;
        final stageGap = compact ? 6.0 : 8.0;
        final state = widget.state;
        final timerColor = state.isOvertime
            ? const Color(0xFFC56A2D)
            : state.phase == TimerPhase.breakTime ||
                    state.phase == TimerPhase.pausedBreak
                ? const Color(0xFF5E6C7B)
                : const Color(0xFF2F3A44);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: widget.selectedSubject,
                    onTap: widget.onSubjectTap,
                  ),
                ),
                SizedBox(width: compact ? 8 : 10),
                Expanded(
                  child: PillButton(
                    label: widget.selectedTopic,
                    onTap: widget.onTopicTap,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 8 : 10),
            _RepeatSettingsToggleButton(
              questionCount: state.totalQuestions,
              breakDurationSec: state.breakDurationSec,
              expanded: _isRepeatSettingsExpanded,
              enabled: widget.canAdjustContinuousSettings,
              onTap: widget.canAdjustContinuousSettings
                  ? () {
                      setState(() {
                        _isRepeatSettingsExpanded = !_isRepeatSettingsExpanded;
                      });
                    }
                  : null,
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _RepeatExamPanel(
                  state: state,
                  compact: compact,
                  enabled: widget.canAdjustContinuousSettings,
                  onDecreaseQuestionCount: widget.onDecreaseQuestionCount,
                  onIncreaseQuestionCount: widget.onIncreaseQuestionCount,
                  onDecreaseBreakDuration: widget.onDecreaseBreakDuration,
                  onIncreaseBreakDuration: widget.onIncreaseBreakDuration,
                ),
              ),
              crossFadeState: _isRepeatSettingsExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
              sizeCurve: Curves.easeOutCubic,
            ),
            SizedBox(height: sectionGap),
            SizedBox(
              height: compact ? 108 : 124,
              child: Row(
                children: [
                  SizedBox(
                    width: compact ? 50 : 56,
                    child: widget.canAdjustDuration
                        ? _DurationStepButton(
                            icon: Icons.remove_rounded,
                            onTap:
                                state.plannedDurationSec >
                                    TimerConstants.minExamTotalSeconds
                                ? widget.onDecreaseDuration
                                : null,
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(width: compact ? 6 : 10),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _mainTimeText(state),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: timerFontSize,
                            fontWeight: FontWeight.w300,
                            height: 0.92,
                            letterSpacing: -3.8,
                            color: timerColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 6 : 10),
                  SizedBox(
                    width: compact ? 50 : 56,
                    child: widget.canAdjustDuration
                        ? _DurationStepButton(
                            icon: Icons.add_rounded,
                            onTap: widget.onIncreaseDuration,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            SizedBox(height: progressGap),
            _SessionProgressBar(
              state: state,
              compact: compact,
            ),
            SizedBox(height: sectionGap),
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
                      onTap: () => widget.onStageSelected(index),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: sectionGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleControlButton(
                  icon: widget.primaryIcon,
                  onTap: widget.primaryAction,
                  enabled: widget.primaryAction != null,
                ),
                const SizedBox(width: 22),
                CircleControlButton(
                  icon: Icons.refresh_rounded,
                  onTap: widget.canReset ? widget.onReset : null,
                  enabled: widget.canReset,
                ),
                const SizedBox(width: 22),
                CircleControlButton(
                  icon: Icons.stop_rounded,
                  onTap: widget.canStop ? widget.onStop : null,
                  enabled: widget.canStop,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _mainTimeText(TimerSessionState state) {
    if (state.phase == TimerPhase.prep || state.phase == TimerPhase.pausedPrep) {
      return formatSeconds(state.prepRemaining);
    }

    if (state.phase == TimerPhase.breakTime ||
        state.phase == TimerPhase.pausedBreak) {
      return formatSeconds(state.breakRemaining);
    }

    if (state.phase == TimerPhase.idle) {
      return formatSeconds(state.plannedDurationSec);
    }

    if (state.isOvertime) {
      return '+${formatSeconds(state.overtimeSeconds)}';
    }

    return formatSeconds(state.examRemaining);
  }
}

class _RepeatSettingsToggleButton extends StatelessWidget {
  const _RepeatSettingsToggleButton({
    required this.questionCount,
    required this.breakDurationSec,
    required this.expanded,
    required this.enabled,
    required this.onTap,
  });

  final int questionCount;
  final int breakDurationSec;
  final bool expanded;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EDF3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '반복 시험 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F3A44),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '$questionCount문항 · 휴식 ${_formatBreakDuration(breakDurationSec)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? const Color(0xFF6C7784)
                        : const Color(0xFF9AA6B2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                color: enabled ? const Color(0xFF6C7784) : const Color(0xFF9AA6B2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepeatExamPanel extends StatelessWidget {
  const _RepeatExamPanel({
    required this.state,
    required this.compact,
    required this.enabled,
    required this.onDecreaseQuestionCount,
    required this.onIncreaseQuestionCount,
    required this.onDecreaseBreakDuration,
    required this.onIncreaseBreakDuration,
  });

  final TimerSessionState state;
  final bool compact;
  final bool enabled;
  final VoidCallback onDecreaseQuestionCount;
  final VoidCallback onIncreaseQuestionCount;
  final VoidCallback onDecreaseBreakDuration;
  final VoidCallback onIncreaseBreakDuration;

  @override
  Widget build(BuildContext context) {
    final questionTile = _RepeatSettingTile(
      label: '문항 수',
      value: '${state.totalQuestions}문항',
      enabled: enabled,
      onDecrease:
          state.totalQuestions > TimerConstants.minContinuousQuestionCount
          ? onDecreaseQuestionCount
          : null,
      onIncrease: state.totalQuestions < TimerConstants.maxContinuousQuestionCount
          ? onIncreaseQuestionCount
          : null,
    );
    final breakTile = _RepeatSettingTile(
      label: '중간 휴식',
      value: _formatBreakDuration(state.breakDurationSec),
      enabled: enabled,
      onDecrease: state.breakDurationSec > 0 ? onDecreaseBreakDuration : null,
      onIncrease: state.breakDurationSec < TimerConstants.maxBreakSeconds
          ? onIncreaseBreakDuration
          : null,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECF2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.58),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '반복 기록은 주제없음으로 저장됩니다.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Color(0xFF6D7885),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${state.currentQuestion}/${state.totalQuestions}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5E6C7B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          compact
              ? Column(
                  children: [
                    questionTile,
                    const SizedBox(height: 12),
                    breakTile,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: questionTile),
                    const SizedBox(width: 12),
                    Expanded(child: breakTile),
                  ],
                ),
        ],
      ),
    );
  }
}

class _RepeatSettingTile extends StatelessWidget {
  const _RepeatSettingTile({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final bool enabled;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A8591),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStepButton(
                icon: Icons.remove_rounded,
                onTap: enabled ? onDecrease : null,
              ),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: enabled
                        ? const Color(0xFF2F3A44)
                        : const Color(0xFF9AA6B2),
                  ),
                ),
              ),
              _MiniStepButton(
                icon: Icons.add_rounded,
                onTap: enabled ? onIncrease : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionProgressBar extends StatelessWidget {
  const _SessionProgressBar({
    required this.state,
    required this.compact,
  });

  final TimerSessionState state;
  final bool compact;

  bool get _isPrepPhase =>
      state.phase == TimerPhase.prep || state.phase == TimerPhase.pausedPrep;

  bool get _isBreakPhase =>
      state.phase == TimerPhase.breakTime || state.phase == TimerPhase.pausedBreak;

  int get _currentSeconds {
    if (_isPrepPhase) {
      return (TimerConstants.prepTotalSeconds - state.prepRemaining).clamp(
        0,
        TimerConstants.prepTotalSeconds,
      );
    }

    if (_isBreakPhase) {
      return (state.breakDurationSec - state.breakRemaining).clamp(
        0,
        state.breakDurationSec,
      );
    }

    return state.examElapsed.clamp(0, state.plannedDurationSec);
  }

  int get _totalSeconds {
    if (_isPrepPhase) {
      return TimerConstants.prepTotalSeconds;
    }
    if (_isBreakPhase) {
      return state.breakDurationSec == 0 ? 1 : state.breakDurationSec;
    }
    return state.plannedDurationSec;
  }

  double get _progressValue {
    if (state.isOvertime) {
      return 1;
    }

    if (_totalSeconds == 0) {
      return 0;
    }

    return (_currentSeconds / _totalSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: compact ? 3 : 4,
        color: Colors.black.withValues(alpha: 0.12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            widthFactor: _progressValue,
            child: Container(
              height: double.infinity,
              color: _isBreakPhase
                  ? const Color(0xFF7A8794)
                  : Colors.black.withValues(alpha: 0.78),
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationStepButton extends StatelessWidget {
  const _DurationStepButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFFF2F5F9)
                : const Color(0xFFE0E6EC),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: enabled ? 0.8 : 0.45),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: enabled ? const Color(0xFF2F3A44) : const Color(0xFF9DA8B4),
          ),
        ),
      ),
    );
  }
}

class _MiniStepButton extends StatelessWidget {
  const _MiniStepButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFFE4EAF1)
                : const Color(0xFFDDE3EA),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? const Color(0xFF2F3A44) : const Color(0xFF9DA8B4),
          ),
        ),
      ),
    );
  }
}

String _formatBreakDuration(int seconds) {
  if (seconds <= 0) {
    return '없음';
  }

  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  if (minutes == 0) {
    return '${remainingSeconds}초';
  }
  if (remainingSeconds == 0) {
    return '${minutes}분';
  }
  return '${minutes}분 ${remainingSeconds}초';
}
