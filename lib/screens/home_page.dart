import 'package:flutter/material.dart';

import '../controllers/home_timer_controller.dart';
import '../core/constants/exam_options.dart';
import '../core/enums/exam_stage.dart';
import '../core/enums/timer_phase.dart';
import '../models/practice_record.dart';
import '../models/timer_session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../widgets/home/control_panel.dart';
import '../widgets/home/stage_summary_card.dart';
import '../widgets/home/timer_display_card.dart';
import 'records_page.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeTimerController _controller = HomeTimerController();
  final TextEditingController _examNameController = TextEditingController();

  int _selectedTab = 0;
  String _selectedSubject = defaultSubject;
  String _selectedTopic = defaultTopic;
  bool _hasSelectedSubject = false;
  bool _hasSelectedTopic = false;

  @override
  void initState() {
    super.initState();
    _controller.onTwoMinuteAlert = _showTwoMinuteAlert;
    _controller.onSessionFinished = _openResultPage;
    _controller.loadRecords();
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _controller.disposeController();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openResultPage(PracticeRecord record) async {
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ResultPage(record: record)));
  }

  Future<void> _confirmReset() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('초기화'),
          content: const Text('현재 진행 중인 기록을 초기화할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('초기화'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _controller.resetSession();
    }
  }

  Future<void> _confirmEndEarly() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('시험 종료'),
          content: const Text('시험을 조기 종료할까요? 현재까지의 시간은 저장됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('종료'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _controller.finishSession(endType: '조기 종료');
    }
  }

  Future<void> _confirmClearAllRecords() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('기록 삭제'),
          content: const Text('저장된 모든 기록을 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _controller.clearAllRecords();
    }
  }

  Future<void> _confirmDeleteRecord(PracticeRecord record) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('기록 삭제'),
          content: Text('"${record.examName}" 기록을 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _controller.deleteRecord(record.id);
    }
  }

  void _showTwoMinuteAlert() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('시험 종료 2분 전입니다.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _switchStageByIndex(int index) {
    _controller.switchStage(ExamStage.values[index]);
  }

  void _updateSubject(String? value) {
    setState(() {
      _selectedSubject = sanitizeSubject(value);
      _selectedTopic = defaultTopic;
      _hasSelectedSubject = true;
      _hasSelectedTopic = false;
    });
  }

  void _updateTopic(String? value) {
    setState(() {
      _selectedTopic = sanitizeTopicForSubject(_selectedSubject, value);
      _hasSelectedTopic = true;
    });
  }

  Future<void> _pickSubject() async {
    final selected = await _showOptionPicker(
      title: '시험 과목',
      options: examSubjects,
      currentValue: _selectedSubject,
    );
    if (selected != null) {
      _updateSubject(selected);
    }
  }

  Future<void> _pickTopic() async {
    final selected = await _showOptionPicker(
      title: '시험 주제',
      options: topicsForSubject(_selectedSubject),
      currentValue: _selectedTopic,
    );
    if (selected != null) {
      _updateTopic(selected);
    }
  }

  Future<String?> _showOptionPicker({
    required String title,
    required List<String> options,
    required String currentValue,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              for (final option in options)
                ListTile(
                  title: Text(option),
                  trailing: option == currentValue
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        );
      },
    );
  }

  void _startSession() {
    _controller.startSession(
      examName: _examNameController.text,
      subject: _selectedSubject,
      topic: _selectedTopic,
    );
  }

  String _primaryButtonLabel(TimerSessionState state) {
    if (state.phase == TimerPhase.pausedPrep ||
        state.phase == TimerPhase.pausedExam) {
      return '재개';
    }

    if (state.phase == TimerPhase.prep) {
      return '바로 시작';
    }

    if (state.phase == TimerPhase.exam) {
      return '일시정지';
    }

    return '시작';
  }

  IconData _primaryButtonIcon(TimerSessionState state) {
    if (state.phase == TimerPhase.pausedPrep ||
        state.phase == TimerPhase.pausedExam) {
      return Icons.play_arrow_rounded;
    }

    if (state.phase == TimerPhase.prep) {
      return Icons.skip_next_rounded;
    }

    if (state.phase == TimerPhase.exam) {
      return Icons.pause_rounded;
    }

    return Icons.play_arrow_rounded;
  }

  VoidCallback? _primaryButtonAction(TimerSessionState state) {
    if (state.phase == TimerPhase.pausedPrep ||
        state.phase == TimerPhase.pausedExam) {
      return _controller.resumeSession;
    }

    if (state.phase == TimerPhase.prep) {
      return _controller.skipPrepAndStartExam;
    }

    if (state.phase == TimerPhase.exam) {
      return _controller.pauseSession;
    }

    if (state.phase == TimerPhase.idle || state.phase == TimerPhase.finished) {
      return _startSession;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: _selectedTab == 0
                ? _TimerTab(
                    state: state,
                    controller: _controller,
                    examNameController: _examNameController,
                    selectedSubject: _selectedSubject,
                    selectedTopic: _selectedTopic,
                    hasSelectedSubject: _hasSelectedSubject,
                    hasSelectedTopic: _hasSelectedTopic,
                    onSubjectTap: _pickSubject,
                    onTopicTap: _pickTopic,
                    onReset: _confirmReset,
                    onStop: _confirmEndEarly,
                    primaryAction: _primaryButtonAction(state),
                    primaryIcon: _primaryButtonIcon(state),
                    primaryLabel: _primaryButtonLabel(state),
                    onStageSelected: _switchStageByIndex,
                  )
                : RecordsPage(
                    records: state.records,
                    onOpenRecord: _openResultPage,
                    onDeleteRecord: _confirmDeleteRecord,
                    onClearAll: _confirmClearAllRecords,
                  ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: _BottomNav(
              selectedTab: _selectedTab,
              onTabChanged: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
            ),
          ),
        );
      },
    );
  }
}

class _TimerTab extends StatelessWidget {
  const _TimerTab({
    required this.state,
    required this.controller,
    required this.examNameController,
    required this.selectedSubject,
    required this.selectedTopic,
    required this.hasSelectedSubject,
    required this.hasSelectedTopic,
    required this.onSubjectTap,
    required this.onTopicTap,
    required this.onReset,
    required this.onStop,
    required this.primaryAction,
    required this.primaryIcon,
    required this.primaryLabel,
    required this.onStageSelected,
  });

  final TimerSessionState state;
  final HomeTimerController controller;
  final TextEditingController examNameController;
  final String selectedSubject;
  final String selectedTopic;
  final bool hasSelectedSubject;
  final bool hasSelectedTopic;
  final VoidCallback onSubjectTap;
  final VoidCallback onTopicTap;
  final VoidCallback onReset;
  final VoidCallback onStop;
  final VoidCallback? primaryAction;
  final IconData primaryIcon;
  final String primaryLabel;
  final ValueChanged<int> onStageSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: AppStyles.headerGradient,
            ),
          ),
        ),
        ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          children: [
            TimerDisplayCard(
              state: state,
              examNameController: examNameController,
              selectedSubject: selectedSubject,
              selectedTopic: selectedTopic,
              hasSelectedSubject: hasSelectedSubject,
              hasSelectedTopic: hasSelectedTopic,
              onSubjectTap: onSubjectTap,
              onTopicTap: onTopicTap,
              onStageSelected: onStageSelected,
            ),
            const SizedBox(height: 12),
            ControlPanel(
              primaryAction: primaryAction,
              primaryIcon: primaryIcon,
              primaryLabel: primaryLabel,
              onReset: onReset,
              onStop: onStop,
              canReset:
                  state.isRunning ||
                  state.isPaused ||
                  state.phase == TimerPhase.finished,
              canStop: state.isExamActive,
            ),
            const SizedBox(height: 12),
            StageSummaryCard(
              state: state,
              previewStageSeconds: controller.previewStageSeconds,
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedTab,
    required this.onTabChanged,
  });

  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.timer_outlined,
            label: '타이머',
            selected: selectedTab == 0,
            onTap: () => onTabChanged(0),
          ),
          _BottomNavItem(
            icon: Icons.history_rounded,
            label: '기록',
            selected: selectedTab == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected
                    ? AppColors.primaryTextOn
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
