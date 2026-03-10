import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/practice_record.dart';
import '../screens/result_page.dart';
import '../services/record_storage.dart';
import '../utils/formatters.dart';
import '../widgets/info_chip.dart';
import '../widgets/round_control_button.dart';
import '../widgets/stage_row.dart';
import '../utils/formatters.dart';

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
      const SnackBar(
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
      appBar: AppBar(
        toolbarHeight: 30,
        title: const SizedBox.shrink(),
        centerTitle: false,
        actions: [
          if (_selectedTab == 1 && _records.isNotEmpty)
            IconButton(
              onPressed: _clearAllRecords,
              icon: const Icon(Icons.delete_outline),
              tooltip: '기록 전체 삭제',
            ),
        ],
      ),
      body: SafeArea(child: pages[_selectedTab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '타이머',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: '기록',
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPage() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildStatusCard(),
        const SizedBox(height: 12),
        _buildActionPanel(),
        const SizedBox(height: 12),
        _buildStageSummaryCard(),
      ],
    );
  }

  Widget _buildStatusCard() {
    final isWarning = _phase == TimerPhase.exam && _examRemaining <= 120;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;

        final timerText = FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _mainTimeText,
            maxLines: 1,
            style: TextStyle(
              fontSize: isNarrow ? 68 : 78,
              fontWeight: FontWeight.w800,
              color: isWarning ? Colors.red : null,
              height: 1,
            ),
          ),
        );

        final infoColumn = Column(
          crossAxisAlignment:
              isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              '현재 단계',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _currentStage?.label ?? '-',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );

        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isWarning ? Colors.red : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: timerText,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: infoColumn,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStageButtons() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('단계 전환', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final stage in ExamStage.values) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: _isExamActive ? () => _switchStage(stage) : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text(
                    stage.label +
                        (_currentStage == stage && _isExamActive ? '  (현재)' : ''),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (stage != ExamStage.values.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStageSummaryCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('단계별 누적 시간',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            StageRow(
              label: ExamStage.historyTaking.label,
              value: formatSeconds(_previewStageSeconds(ExamStage.historyTaking)),
            ),
            const Divider(height: 20),
            StageRow(
              label: ExamStage.physicalExam.label,
              value: formatSeconds(_previewStageSeconds(ExamStage.physicalExam)),
            ),
            const Divider(height: 20),
            StageRow(
              label: ExamStage.patientEducation.label,
              value: formatSeconds(_previewStageSeconds(ExamStage.patientEducation)),
            ),
            const Divider(height: 20),
            StageRow(
              label: '총 사용 시간',
              value: formatSeconds(_examElapsed),
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPanel() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '단계 전환',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RoundControlButton(
                    icon: Icons.question_answer,
                    label: '병력',
                    onTap: _isExamActive
                        ? () => _switchStage(ExamStage.historyTaking)
                        : null,
                    isSelected:
                        _currentStage == ExamStage.historyTaking && _isExamActive,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RoundControlButton(
                    icon: Icons.medical_services,
                    label: '진찰',
                    onTap: _isExamActive
                        ? () => _switchStage(ExamStage.physicalExam)
                        : null,
                    isSelected:
                        _currentStage == ExamStage.physicalExam && _isExamActive,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RoundControlButton(
                    icon: Icons.record_voice_over,
                    label: '교육',
                    onTap: _isExamActive
                        ? () => _switchStage(ExamStage.patientEducation)
                        : null,
                    isSelected: _currentStage == ExamStage.patientEducation &&
                        _isExamActive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 16),
            const SizedBox(height: 2),
            const Text(
              '조작',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RoundControlButton(
                    icon: Icons.play_arrow,
                    label: '시작',
                    onTap: !_isRunning && !_isPaused ? _startSession : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RoundControlButton(
                    icon: _isPaused ? Icons.play_circle : Icons.pause,
                    label: _isPaused ? '재개' : '일시정지',
                    onTap:
                        _isRunning ? _pauseSession : (_isPaused ? _resumeSession : null),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RoundControlButton(
                    icon: Icons.refresh,
                    label: '초기화',
                    onTap: (_isRunning || _isPaused || _phase == TimerPhase.finished)
                        ? _confirmReset
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RoundControlButton(
                    icon: (_phase == TimerPhase.prep ||
                            _phase == TimerPhase.pausedPrep)
                        ? Icons.skip_next
                        : Icons.stop,
                    label: (_phase == TimerPhase.prep ||
                            _phase == TimerPhase.pausedPrep)
                        ? '바로 시작'
                        : '종료',
                    onTap: (_phase == TimerPhase.prep ||
                            _phase == TimerPhase.pausedPrep)
                        ? _skipPrepAndStartExam
                        : (_isExamActive ? _confirmEndEarly : null),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildControlButtons() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '조작',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                RoundControlButton(
                  icon: Icons.play_arrow,
                  label: '시작',
                  onTap: !_isRunning && !_isPaused ? _startSession : null,
                ),
                RoundControlButton(
                  icon: _isPaused ? Icons.play_circle : Icons.pause,
                  label: _isPaused ? '재개' : '일시정지',
                  onTap: _isRunning ? _pauseSession : (_isPaused ? _resumeSession : null),
                ),
                RoundControlButton(
                  icon: Icons.refresh,
                  label: '초기화',
                  onTap: (_isRunning || _isPaused || _phase == TimerPhase.finished)
                      ? _confirmReset
                      : null,
                ),
                RoundControlButton(
                  icon: (_phase == TimerPhase.prep || _phase == TimerPhase.pausedPrep)
                      ? Icons.skip_next
                      : Icons.stop,
                  label: (_phase == TimerPhase.prep || _phase == TimerPhase.pausedPrep)
                      ? '바로 시작'
                      : '종료',
                  onTap: (_phase == TimerPhase.prep || _phase == TimerPhase.pausedPrep)
                      ? _skipPrepAndStartExam
                      : (_isExamActive ? _confirmEndEarly : null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPage() {
    if (_records.isEmpty) {
      return const Center(
        child: Text(
          '아직 저장된 기록이 없습니다.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final record = _records[index];
        return Card(
          elevation: 0,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              _formatDateTime(record.endedAt),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('${record.endType}  ·  ${formatSeconds(record.totalSeconds)}'),
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
    );
  }
}