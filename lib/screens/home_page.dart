import 'package:flutter/material.dart';

import '../controllers/home_timer_controller.dart';
import '../core/constants/exam_options.dart';
import '../core/enums/exam_stage.dart';
import '../core/enums/timer_phase.dart';
import '../models/practice_record.dart';
import '../models/timer_session_state.dart';
import '../widgets/home/glass_card.dart';
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
    final result = await _showThemedConfirmDialog(
      title: '초기화',
      message: '현재 진행 중인 기록을 초기화할까요?',
      confirmLabel: '초기화',
    );

    if (result == true) {
      _controller.resetSession();
    }
  }

  Future<void> _confirmEndEarly() async {
    final result = await _showThemedConfirmDialog(
      title: '세션 종료',
      message: '세션을 조기 종료할까요? 현재까지의 사용 시간만 저장됩니다.',
      confirmLabel: '종료',
    );

    if (result == true) {
      await _controller.finishSession(endType: '조기 종료');
    }
  }

  Future<void> _confirmClearAllRecords() async {
    final result = await _showThemedConfirmDialog(
      title: '기록 삭제',
      message: '저장된 모든 기록을 삭제할까요?',
      confirmLabel: '삭제',
    );

    if (result == true) {
      await _controller.clearAllRecords();
    }
  }

  Future<void> _confirmDeleteRecord(PracticeRecord record) async {
    final result = await _showThemedConfirmDialog(
      title: '기록 삭제',
      message: '"${record.examName}" 기록을 삭제할까요?',
      confirmLabel: '삭제',
    );

    if (result == true) {
      await _controller.deleteRecord(record.id);
    }
  }

  void _showTwoMinuteAlert() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('세션 종료 2분 전입니다.'),
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
    });
  }

  void _updateTopic(String? value) {
    setState(() {
      _selectedTopic = sanitizeTopicForSubject(_selectedSubject, value);
    });
  }

  Future<void> _pickSubject() async {
    final selected = await _showOptionPicker(
      title: '연습 과목',
      options: examSubjects,
      currentValue: _selectedSubject,
    );
    if (selected != null) {
      _updateSubject(selected);
    }
  }

  Future<void> _pickTopic() async {
    final selected = await _showOptionPicker(
      title: '연습 주제',
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
      backgroundColor: const Color(0xFFF3F6F9),
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
                    color: const Color(0xFF2F3A44),
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

  Future<bool?> _showThemedConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: const Color(0x80394652),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: const Color(0xFFE7ECF1),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8397AA).withValues(alpha: 0.14),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F3A44),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Color(0xFF697482),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _DialogActionButton(
                        label: '취소',
                        onTap: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogActionButton(
                        label: confirmLabel,
                        primary: true,
                        onTap: () => Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          extendBody: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE6EEF5),
                  Color(0xFFDCE6EE),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _selectedTab == 0
                        ? _TimerTab(
                            state: state,
                            controller: _controller,
                            examNameController: _examNameController,
                            selectedSubject: _selectedSubject,
                            selectedTopic: _selectedTopic,
                            onSubjectTap: _pickSubject,
                            onTopicTap: _pickTopic,
                            onReset: _confirmReset,
                            onStop: _confirmEndEarly,
                            primaryAction: _primaryButtonAction(state),
                            primaryIcon: _primaryButtonIcon(state),
                            onStageSelected: _switchStageByIndex,
                          )
                        : RecordsPage(
                            records: state.records,
                            onOpenRecord: _openResultPage,
                            onDeleteRecord: _confirmDeleteRecord,
                            onClearAll: _confirmClearAllRecords,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: _BottomNavigationBar(
                      selectedIndex: _selectedTab,
                      onChanged: (index) {
                        setState(() {
                          _selectedTab = index;
                        });
                      },
                    ),
                  ),
                ],
              ),
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
    required this.onSubjectTap,
    required this.onTopicTap,
    required this.onReset,
    required this.onStop,
    required this.primaryAction,
    required this.primaryIcon,
    required this.onStageSelected,
  });

  final TimerSessionState state;
  final HomeTimerController controller;
  final TextEditingController examNameController;
  final String selectedSubject;
  final String selectedTopic;
  final VoidCallback onSubjectTap;
  final VoidCallback onTopicTap;
  final VoidCallback onReset;
  final VoidCallback onStop;
  final VoidCallback? primaryAction;
  final IconData primaryIcon;
  final ValueChanged<int> onStageSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final outerPadding = availableHeight < 760 ? 6.0 : 14.0;
        final gap = availableHeight < 760 ? 12.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(6, outerPadding, 6, outerPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight - outerPadding * 2,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TimerDisplayCard(
                        state: state,
                        examNameController: examNameController,
                        selectedSubject: selectedSubject,
                        selectedTopic: selectedTopic,
                        onSubjectTap: onSubjectTap,
                        onTopicTap: onTopicTap,
                        onStageSelected: onStageSelected,
                        primaryAction: primaryAction,
                        primaryIcon: primaryIcon,
                        onReset: onReset,
                        onStop: onStop,
                        canReset:
                            state.isRunning ||
                            state.isPaused ||
                            state.phase == TimerPhase.finished,
                        canStop: state.isExamActive,
                      ),
                      SizedBox(height: gap),
                      StageSummaryCard(
                        state: state,
                        previewStageSeconds: controller.previewStageSeconds,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomNavItem(
              icon: Icons.timer_outlined,
              label: '타이머',
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              icon: Icons.history_rounded,
              label: '기록',
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
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
    final color =
        selected ? const Color(0xFF2E6BFF) : const Color(0xFF8B939D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final color = primary ? const Color(0xFF2E6BFF) : const Color(0xFF6B7684);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            color: primary ? const Color(0xFFF2F5F9) : const Color(0xFFE1E7ED),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
