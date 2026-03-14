import 'package:flutter/foundation.dart';

import '../core/constants/exam_options.dart';
import '../core/constants/timer_constants.dart';
import '../core/enums/exam_stage.dart';
import '../core/enums/timer_phase.dart';
import '../models/practice_record.dart';
import '../models/timer_session_state.dart';
import '../services/record_storage.dart';
import '../services/timer_service.dart';

class HomeTimerController extends ChangeNotifier {
  HomeTimerController({TimerService? timerService})
    : _timerService = timerService ?? TimerService();

  final TimerService _timerService;

  TimerSessionState _state = TimerSessionState.initial();

  TimerSessionState get state => _state;

  VoidCallback? onTwoMinuteAlert;
  Future<void> Function(PracticeRecord record)? onSessionFinished;

  Future<void> loadRecords() async {
    final records = await RecordStorage.loadRecords();
    _state = _state.copyWith(records: records);
    notifyListeners();
  }

  Future<void> clearAllRecords() async {
    _state = _state.copyWith(records: const []);
    notifyListeners();
    await RecordStorage.saveRecords(_state.records);
  }

  Future<void> deleteRecord(String id) async {
    _state = _state.copyWith(
      records: _state.records.where((record) => record.id != id).toList(),
    );
    notifyListeners();
    await RecordStorage.saveRecords(_state.records);
  }

  void startSession({String? examName, String? subject, String? topic}) {
    final normalizedSubject = sanitizeSubject(subject);
    final normalizedExamName = sanitizeExamName(examName);
    final normalizedTopic = sanitizeTopicForSubject(normalizedSubject, topic);

    _timerService.cancelTimer();
    _state = TimerSessionState.initial().copyWith(
      phase: TimerPhase.prep,
      sessionExamName: normalizedExamName,
      sessionSubject: normalizedSubject,
      sessionTopic: normalizedTopic,
      records: _state.records,
    );
    notifyListeners();
    _startPrepTicker();
  }

  void skipPrepAndStartExam() {
    if (_state.phase != TimerPhase.prep &&
        _state.phase != TimerPhase.pausedPrep) {
      return;
    }
    _startExam();
  }

  void pauseSession() {
    _timerService.cancelTimer();

    if (_state.phase == TimerPhase.prep) {
      _state = _state.copyWith(phase: TimerPhase.pausedPrep);
    } else if (_state.phase == TimerPhase.exam) {
      _state = _state.copyWith(phase: TimerPhase.pausedExam);
    } else {
      return;
    }

    notifyListeners();
  }

  void resumeSession() {
    if (_state.phase == TimerPhase.pausedPrep) {
      _state = _state.copyWith(phase: TimerPhase.prep);
      notifyListeners();
      _startPrepTicker();
      return;
    }

    if (_state.phase == TimerPhase.pausedExam) {
      _state = _state.copyWith(phase: TimerPhase.exam);
      notifyListeners();
      _startExamTicker();
    }
  }

  void switchStage(ExamStage newStage) {
    if (_state.phase != TimerPhase.exam || _state.currentStage == null) return;
    if (_state.currentStage == newStage) return;

    _commitCurrentStageTime();
    _state = _state.copyWith(
      currentStage: newStage,
      examElapsedAtStageStart: _state.examElapsed,
    );
    notifyListeners();
  }

  Future<void> finishSession({required String endType}) async {
    _timerService.cancelTimer();
    _timerService.playSound('end.mp3');

    if (_state.phase == TimerPhase.exam ||
        _state.phase == TimerPhase.pausedExam) {
      _commitCurrentStageTime();
    }

    final record = PracticeRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      examName: _state.sessionExamName,
      subject: _state.sessionSubject,
      topic: _state.sessionTopic,
      endedAt: DateTime.now(),
      totalSeconds: _state.examElapsed,
      historySeconds: _state.stageSeconds[ExamStage.historyTaking] ?? 0,
      physicalSeconds: _state.stageSeconds[ExamStage.physicalExam] ?? 0,
      educationSeconds: _state.stageSeconds[ExamStage.patientEducation] ?? 0,
      endType: endType,
    );

    _state = _state.copyWith(
      phase: TimerPhase.finished,
      records: [record, ..._state.records],
    );
    notifyListeners();

    await RecordStorage.saveRecords(_state.records);
    await onSessionFinished?.call(record);
  }

  void resetSession() {
    _timerService.cancelTimer();
    _state = TimerSessionState.initial().copyWith(records: _state.records);
    notifyListeners();
  }

  int previewStageSeconds(ExamStage stage) {
    var base = _state.stageSeconds[stage] ?? 0;
    if (_state.isExamActive && _state.currentStage == stage) {
      final delta = _state.examElapsed - _state.examElapsedAtStageStart;
      if (delta > 0) {
        base += delta;
      }
    }
    return base;
  }

  Future<void> disposeController() async {
    await _timerService.dispose();
  }

  void _startPrepTicker() {
    _timerService.startPeriodic(
      duration: const Duration(seconds: 1),
      onTick: (_) {
        if (_state.phase != TimerPhase.prep) return;

        if (_state.prepRemaining > 1) {
          _state = _state.copyWith(prepRemaining: _state.prepRemaining - 1);
          notifyListeners();
          return;
        }

        _state = _state.copyWith(prepRemaining: 0);
        notifyListeners();
        _startExam();
      },
    );
  }

  void _startExam() {
    _timerService.cancelTimer();
    _state = _state.copyWith(
      phase: TimerPhase.exam,
      examRemaining: TimerConstants.examTotalSeconds,
      currentStage: ExamStage.historyTaking,
      examElapsedAtStageStart: 0,
      twoMinuteAlertShown: false,
    );
    notifyListeners();
    _timerService.playSound('start.mp3');
    _startExamTicker();
  }

  void _startExamTicker() {
    _timerService.startPeriodic(
      duration: const Duration(seconds: 1),
      onTick: (_) {
        if (_state.phase != TimerPhase.exam) return;

        if (_state.examRemaining > 1) {
          final nextRemaining = _state.examRemaining - 1;
          _state = _state.copyWith(examRemaining: nextRemaining);
          notifyListeners();

          if (nextRemaining == TimerConstants.twoMinuteWarningSeconds &&
              !_state.twoMinuteAlertShown) {
            _state = _state.copyWith(twoMinuteAlertShown: true);
            notifyListeners();
            onTwoMinuteAlert?.call();
            _timerService.playSound('warning.mp3');
          }
          return;
        }

        _state = _state.copyWith(examRemaining: 0);
        notifyListeners();
        finishSession(endType: '정상 종료');
      },
    );
  }

  void _commitCurrentStageTime() {
    final currentStage = _state.currentStage;
    if (currentStage == null) return;

    final delta = _state.examElapsed - _state.examElapsedAtStageStart;
    if (delta <= 0) return;

    final updated = Map<ExamStage, int>.from(_state.stageSeconds);
    updated[currentStage] = (updated[currentStage] ?? 0) + delta;
    _state = _state.copyWith(stageSeconds: updated);
  }
}
