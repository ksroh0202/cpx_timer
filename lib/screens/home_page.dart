import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/practice_record.dart';
import '../screens/result_page.dart';
import '../services/record_storage.dart';
import '../utils/formatters.dart';
import '../widgets/stage_row.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

enum TimerPhase {
  idle,
  prep,
  exam,
  pausedPrep,
  pausedExam,
  finished,
}

enum ExamStage {
  historyTaking,
  physicalExam,
  patientEducation,
}

extension ExamStageLabel on ExamStage {
  String get label {
    switch (this) {
      case ExamStage.historyTaking:
        return '병력 청취';
      case ExamStage.physicalExam:
        return '신체 진찰';
      case ExamStage.patientEducation:
        return '환자 교육';
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int prepTotalSeconds = 60;
  static const int examTotalSeconds = 12 * 60;
  static const String prefsKey = 'cpx_records';

  Timer? _timer;
  TimerPhase _phase = TimerPhase.idle;

  int _prepRemaining = prepTotalSeconds;
  int _examRemaining = examTotalSeconds;

  ExamStage? _currentStage;
  int _examElapsedAtStageStart = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playSound(String fileName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (_) {
      // 소리 재생 실패 시 앱이 멈추지 않게 무시
    }
  }

  final Map<ExamStage, int> _stageSeconds = {
    ExamStage.historyTaking: 0,
    ExamStage.physicalExam: 0,
    ExamStage.patientEducation: 0,
  };

  List<PracticeRecord> _records = [];
  int _selectedTab = 0;
  bool _twoMinuteAlertShown = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

    Future<void> _loadRecords() async {
    final parsed = await RecordStorage.loadRecords();

    setState(() {
        _records = parsed;
    });
    }

    Future<void> _saveRecords() async {
    await RecordStorage.saveRecords(_records);
    }

  void _startSession() {
    _timer?.cancel();

    setState(() {
      _phase = TimerPhase.prep;
      _prepRemaining = prepTotalSeconds;
      _examRemaining = examTotalSeconds;
      _currentStage = null;
      _examElapsedAtStageStart = 0;
      _twoMinuteAlertShown = false;

      for (final stage in ExamStage.values) {
        _stageSeconds[stage] = 0;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phase == TimerPhase.prep) {
        if (_prepRemaining > 1) {
          setState(() {
            _prepRemaining--;
          });
        } else {
          setState(() {
            _prepRemaining = 0;
          });
          _startExam();
        }
      }
    });
  }

  void _startExam() {
    _timer?.cancel();

    setState(() {
      _phase = TimerPhase.exam;
      _examRemaining = examTotalSeconds;
      _currentStage = ExamStage.historyTaking;
      _examElapsedAtStageStart = 0;
    });

    _playSound('start.mp3');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phase == TimerPhase.exam) {
        if (_examRemaining > 1) {
          setState(() {
            _examRemaining--;
          });

          if (_examRemaining == 120 && !_twoMinuteAlertShown) {
            _twoMinuteAlertShown = true;
            _showTwoMinuteAlert();
            _playSound('warning.mp3');
          }
        } else {
          setState(() {
            _examRemaining = 0;
          });
          _finishSession(endType: '정상 종료');
        }
      }
    });
  }

  void _skipPrepAndStartExam() {
    if (_phase != TimerPhase.prep && _phase != TimerPhase.pausedPrep) return;
    _startExam();
  }

  void _pauseSession() {
    _timer?.cancel();

    setState(() {
      if (_phase == TimerPhase.prep) {
        _phase = TimerPhase.pausedPrep;
      } else if (_phase == TimerPhase.exam) {
        _phase = TimerPhase.pausedExam;
      }
    });
  }

  void _resumeSession() {
    if (_phase == TimerPhase.pausedPrep) {
      setState(() {
        _phase = TimerPhase.prep;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_phase == TimerPhase.prep) {
          if (_prepRemaining > 1) {
            setState(() {
              _prepRemaining--;
            });
          } else {
            setState(() {
              _prepRemaining = 0;
            });
            _startExam();
          }
        }
      });
    } else if (_phase == TimerPhase.pausedExam) {
      setState(() {
        _phase = TimerPhase.exam;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_phase == TimerPhase.exam) {
          if (_examRemaining > 1) {
            setState(() {
              _examRemaining--;
            });

            if (_examRemaining == 120 && !_twoMinuteAlertShown) {
              _twoMinuteAlertShown = true;
              _showTwoMinuteAlert();
              _playSound('warning.mp3');
            }
          } else {
            setState(() {
              _examRemaining = 0;
            });
            _finishSession(endType: '정상 종료');
          }
        }
      });
    }
  }

  void _switchStage(ExamStage newStage) {
    if (_phase != TimerPhase.exam || _currentStage == null) return;
    if (_currentStage == newStage) return;

    _commitCurrentStageTime();

    setState(() {
      _currentStage = newStage;
      _examElapsedAtStageStart = _examElapsed;
    });
  }

  void _commitCurrentStageTime() {
    if (_currentStage == null) return;

    final nowElapsed = _examElapsed;
    final delta = nowElapsed - _examElapsedAtStageStart;

    if (delta > 0) {
      _stageSeconds[_currentStage!] = (_stageSeconds[_currentStage!] ?? 0) + delta;
    }
  }

  Future<void> _finishSession({required String endType}) async {

    _playSound('end.mp3');

    _timer?.cancel();

    if (_phase == TimerPhase.exam || _phase == TimerPhase.pausedExam) {
      _commitCurrentStageTime();
    }

    final record = PracticeRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      endedAt: DateTime.now(),
      totalSeconds: _examElapsed,
      historySeconds: _stageSeconds[ExamStage.historyTaking] ?? 0,
      physicalSeconds: _stageSeconds[ExamStage.physicalExam] ?? 0,
      educationSeconds: _stageSeconds[ExamStage.patientEducation] ?? 0,
      endType: endType,
    );

    setState(() {
      _phase = TimerPhase.finished;
      _records.insert(0, record);
    });

    await _saveRecords();

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultPage(record: record),
      ),
    );
  }

  void _resetSession() {
    _timer?.cancel();

    setState(() {
      _phase = TimerPhase.idle;
      _prepRemaining = prepTotalSeconds;
      _examRemaining = examTotalSeconds;
      _currentStage = null;
      _examElapsedAtStageStart = 0;
      _twoMinuteAlertShown = false;

      for (final stage in ExamStage.values) {
        _stageSeconds[stage] = 0;
      }
    });
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
      _resetSession();
    }
  }

  Future<void> _confirmEndEarly() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('시험 종료'),
          content: const Text('시험을 조기 종료할까요? 현재까지의 시간이 저장됩니다.'),
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
      _finishSession(endType: '조기 종료');
    }
  }

  Future<void> _clearAllRecords() async {
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
      setState(() {
        _records.clear();
      });
      await _saveRecords();
    }
  }

  void _showTwoMinuteAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('시험 종료 2분 전입니다.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  int get _examElapsed => examTotalSeconds - _examRemaining;

  String get _statusText {
    switch (_phase) {
      case TimerPhase.idle:
        return '대기';
      case TimerPhase.prep:
        return '준비시간';
      case TimerPhase.exam:
        if (_examRemaining <= 120) return '2분 남음';
        return '시험 진행 중';
      case TimerPhase.pausedPrep:
        return '준비시간 일시정지';
      case TimerPhase.pausedExam:
        return '시험 일시정지';
      case TimerPhase.finished:
        return '시험 종료';
    }
  }

  String get _mainTimeText {
    if (_phase == TimerPhase.prep || _phase == TimerPhase.pausedPrep) {
      return formatSeconds(_prepRemaining);
    }
    if (_phase == TimerPhase.exam ||
        _phase == TimerPhase.pausedExam ||
        _phase == TimerPhase.finished) {
      return formatSeconds(_examRemaining);
    }
    return formatSeconds(examTotalSeconds);
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  bool get _isRunning => _phase == TimerPhase.prep || _phase == TimerPhase.exam;
  bool get _isPaused =>
      _phase == TimerPhase.pausedPrep || _phase == TimerPhase.pausedExam;
  bool get _isExamActive =>
      _phase == TimerPhase.exam || _phase == TimerPhase.pausedExam;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTimerPage(),
      _buildHistoryPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: pages[_selectedTab]),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerPage() {
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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildActionPanel(),
            const SizedBox(height: 16),
            _buildStageSummaryCard(),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final progress = _phase == TimerPhase.prep || _phase == TimerPhase.pausedPrep
        ? 1 - (_prepRemaining / prepTotalSeconds)
        : 1 - (_examRemaining / examTotalSeconds);

    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _statusText,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              _mainTimeText,
              style: AppStyles.timerText,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              _currentStage?.label ?? _statusText,
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
          _buildStageSegmentedControl(),
        ],
      ),
    );
  }

  Widget _buildStageSegmentedControl() {
    Widget stageItem({
      required String text,
      required bool selected,
      required VoidCallback? onTap,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: selected ? null : Colors.transparent,
              borderRadius: AppStyles.cardInnerRadius,
            ),
            child: Center(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? AppColors.primaryTextOn
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: AppStyles.softPillDecoration,
      child: Row(
        children: [
          stageItem(
            text: '병력',
            selected: _currentStage == ExamStage.historyTaking && _isExamActive,
            onTap: _isExamActive
                ? () => _switchStage(ExamStage.historyTaking)
                : null,
          ),
          stageItem(
            text: '진찰',
            selected: _currentStage == ExamStage.physicalExam && _isExamActive,
            onTap: _isExamActive
                ? () => _switchStage(ExamStage.physicalExam)
                : null,
          ),
          stageItem(
            text: '교육',
            selected: _currentStage == ExamStage.patientEducation && _isExamActive,
            onTap: _isExamActive
                ? () => _switchStage(ExamStage.patientEducation)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStageSummaryCard() {
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
            value: formatSeconds(_previewStageSeconds(ExamStage.historyTaking)),
          ),
          const Divider(color: AppColors.line, height: 1),
          StageRow(
            label: ExamStage.physicalExam.label,
            value: formatSeconds(_previewStageSeconds(ExamStage.physicalExam)),
          ),
          const Divider(color: AppColors.line, height: 1),
          StageRow(
            label: ExamStage.patientEducation.label,
            value: formatSeconds(_previewStageSeconds(ExamStage.patientEducation)),
          ),
          const Divider(color: AppColors.line, height: 1),
          StageRow(
            label: '총 사용 시간',
            value: formatSeconds(_examElapsed),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: _buildStartPauseButton(
            onTap: _primaryButtonAction(),
            icon: _primaryButtonIcon(),
            label: _primaryButtonLabel(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: _buildSecondaryControlPill(),
        ),
      ],
    );
  }

  String _primaryButtonLabel() {
    if (_phase == TimerPhase.pausedPrep || _phase == TimerPhase.pausedExam) {
      return '재개';
    }

    if (_phase == TimerPhase.prep) {
      return '바로 시작';
    }

    if (_phase == TimerPhase.exam) {
      return '일시정지';
    }

    return '시작';
  }

  IconData _primaryButtonIcon() {
    if (_phase == TimerPhase.pausedPrep || _phase == TimerPhase.pausedExam) {
      return Icons.play_arrow_rounded;
    }

    if (_phase == TimerPhase.prep) {
      return Icons.skip_next_rounded;
    }

    if (_phase == TimerPhase.exam) {
      return Icons.pause_rounded;
    }

    return Icons.play_arrow_rounded;
  }

  VoidCallback? _primaryButtonAction() {
    if (_phase == TimerPhase.pausedPrep || _phase == TimerPhase.pausedExam) {
      return _resumeSession;
    }

    if (_phase == TimerPhase.prep) {
      return _skipPrepAndStartExam;
    }

    if (_phase == TimerPhase.exam) {
      return _pauseSession;
    }

    if (_phase == TimerPhase.idle || _phase == TimerPhase.finished) {
      return _startSession;
    }

    return null;
  }

  Widget _buildStartPauseButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
  }) {
    final disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppStyles.pillRadius,
          onTap: onTap,
          child: Ink(
            height: 64,
            decoration: AppStyles.primaryPillDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: AppColors.primaryTextOn,
                  size: 26,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppStyles.buttonText.copyWith(
                    color: AppColors.primaryTextOn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryControlPill() {
    final canReset = _isRunning || _isPaused || _phase == TimerPhase.finished;
    final canStop = _isExamActive;

    Widget actionButton({
      required IconData icon,
      required VoidCallback? onTap,
    }) {
      final enabled = onTap != null;

      return Expanded(
        child: InkWell(
          borderRadius: AppStyles.pillRadius,
          onTap: onTap,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : 0.4,
              child: Icon(
                icon,
                size: 24,
                color: AppColors.iconSoft,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 64,
      decoration: AppStyles.softPillDecoration,
      child: Row(
        children: [
          actionButton(
            icon: Icons.refresh_rounded,
            onTap: canReset ? _confirmReset : null,
          ),
          Container(
            width: 1,
            height: 28,
            color: AppColors.line,
          ),
          actionButton(
            icon: Icons.stop_rounded,
            onTap: canStop ? _confirmEndEarly : null,
          ),
        ],
      ),
    );
  }

  int _previewStageSeconds(ExamStage stage) {
    int base = _stageSeconds[stage] ?? 0;
    if (_isExamActive && _currentStage == stage) {
      final delta = _examElapsed - _examElapsedAtStageStart;
      if (delta > 0) {
        base += delta;
      }
    }
    return base;
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _selectedTab == 0
                          ? AppColors.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.timer_outlined,
                      color: _selectedTab == 0
                          ? AppColors.primaryTextOn
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '타이머',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedTab == 0
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _selectedTab == 1
                          ? AppColors.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: _selectedTab == 1
                          ? AppColors.primaryTextOn
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '기록',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedTab == 0
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPage() {
    return Column(
      children: [
        if (_records.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _clearAllRecords,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('전체 삭제'),
                ),
              ],
            ),
          ),
        Expanded(
          child: _records.isEmpty
              ? Center(
                  child: Text(
                    '아직 저장된 기록이 없습니다.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: _records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Card(
                      elevation: 0,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          _formatDateTime(record.endedAt),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${record.endType}  ·  ${formatSeconds(record.totalSeconds)}',
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResultPage(record: record),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}