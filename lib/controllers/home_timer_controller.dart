import 'dart:async';

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
  String? _latestFinishedRecordId;

  TimerSessionState get state => _state;
  String? get latestFinishedRecordId => _latestFinishedRecordId;

  VoidCallback? onTwoMinuteAlert;
  Future<void> Function(PracticeRecord record)? onSessionFinished;
  static const String _repeatedTopicLabel = '주제없음';

  void increaseExamDuration() {
    _updateExamDuration(
      _state.plannedDurationSec + TimerConstants.examAdjustmentStepSeconds,
    );
  }

  void decreaseExamDuration() {
    _updateExamDuration(
      _state.plannedDurationSec - TimerConstants.examAdjustmentStepSeconds,
    );
  }

  void increaseQuestionCount() {
    _updateQuestionCount(_state.totalQuestions + 1);
  }

  void decreaseQuestionCount() {
    _updateQuestionCount(_state.totalQuestions - 1);
  }

  void increaseBreakDuration() {
    _updateBreakDuration(
      _state.breakDurationSec + TimerConstants.breakAdjustmentStepSeconds,
    );
  }

  void decreaseBreakDuration() {
    _updateBreakDuration(
      _state.breakDurationSec - TimerConstants.breakAdjustmentStepSeconds,
    );
  }

  Future<void> loadRecords() async {
    final records = await RecordStorage.loadRecords();
    _state = _state.copyWith(records: records);
    notifyListeners();
  }

  Future<void> clearAllRecords() async {
    _latestFinishedRecordId = null;
    _state = _state.copyWith(records: const []);
    notifyListeners();
    await RecordStorage.saveRecords(_state.records);
  }

  Future<void> deleteRecord(String id) async {
    if (_latestFinishedRecordId == id) {
      _latestFinishedRecordId = null;
    }
    _state = _state.copyWith(
      records: _state.records.where((record) => record.id != id).toList(),
    );
    notifyListeners();
    await RecordStorage.saveRecords(_state.records);
  }

  void startSession({String? examName, String? subject, String? topic}) {
    final normalizedSubject = sanitizeSubject(subject);
    final normalizedExamName = sanitizeExamName(examName);
    final normalizedTopic = _resolveSessionTopic(
      normalizedSubject,
      topic,
      totalQuestions: _state.totalQuestions,
    );
    final plannedDurationSec = _state.plannedDurationSec;

    _timerService.cancelTimer();
    _state = TimerSessionState.initial(
      plannedDurationSec: plannedDurationSec,
      totalQuestions: _state.totalQuestions,
      currentQuestion: TimerConstants.minContinuousQuestionCount,
      breakDurationSec: _state.breakDurationSec,
    ).copyWith(
      phase: TimerPhase.prep,
      sessionExamName: normalizedExamName,
      sessionSubject: normalizedSubject,
      sessionTopic: normalizedTopic,
      records: _state.records,
    );
    _latestFinishedRecordId = null;
    notifyListeners();
    _startPrepTicker();
  }

  void updateSessionMetadata({
    String? examName,
    String? subject,
    String? topic,
  }) {
    final normalizedSubject = subject == null
        ? _state.sessionSubject
        : sanitizeSubject(subject);
    final normalizedExamName = examName == null
        ? _state.sessionExamName
        : sanitizeExamName(examName);
    final normalizedTopic = _resolveSessionTopic(
      normalizedSubject,
      topic ?? _state.sessionTopic,
    );

    if (_state.sessionExamName == normalizedExamName &&
        _state.sessionSubject == normalizedSubject &&
        _state.sessionTopic == normalizedTopic) {
      return;
    }

    _state = _state.copyWith(
      sessionExamName: normalizedExamName,
      sessionSubject: normalizedSubject,
      sessionTopic: normalizedTopic,
    );
    notifyListeners();
  }

  Future<PracticeRecord?> syncSessionMetadata({
    String? examName,
    String? subject,
    String? topic,
  }) async {
    updateSessionMetadata(
      examName: examName,
      subject: subject,
      topic: topic,
    );

    if (_state.phase != TimerPhase.finished || _latestFinishedRecordId == null) {
      return null;
    }

    return updateRecordMetadata(
      _latestFinishedRecordId!,
      examName: examName,
      subject: subject,
      topic: topic,
    );
  }

  Future<PracticeRecord?> updateRecordMetadata(
    String id, {
    String? examName,
    String? subject,
    String? topic,
  }) async {
    final index = _state.records.indexWhere((record) => record.id == id);
    if (index < 0) {
      return null;
    }

    final updatedRecord = _state.records[index].copyWith(
      examName: examName,
      subject: subject,
      topic: topic,
    );
    await updateRecord(updatedRecord);
    return updatedRecord;
  }

  Future<void> updateRecord(PracticeRecord updatedRecord) async {
    final index = _state.records.indexWhere(
      (record) => record.id == updatedRecord.id,
    );
    if (index < 0) {
      return;
    }

    final updatedRecords = List<PracticeRecord>.from(_state.records);
    updatedRecords[index] = updatedRecord;

    _state = _state.copyWith(
      records: updatedRecords,
      sessionExamName: _latestFinishedRecordId == updatedRecord.id
          ? updatedRecord.examName
          : _state.sessionExamName,
      sessionSubject: _latestFinishedRecordId == updatedRecord.id
          ? updatedRecord.subject
          : _state.sessionSubject,
      sessionTopic: _latestFinishedRecordId == updatedRecord.id
          ? updatedRecord.topic
          : _state.sessionTopic,
    );
    notifyListeners();

    await RecordStorage.saveRecords(_state.records);
  }

  void skipPrepAndStartExam() {
    if (_state.phase != TimerPhase.prep &&
        _state.phase != TimerPhase.pausedPrep) {
      return;
    }
    _startExam();
  }

  void skipBreakAndStartNextQuestion() {
    if (_state.phase != TimerPhase.breakTime &&
        _state.phase != TimerPhase.pausedBreak) {
      return;
    }
    _startPrepForCurrentQuestion();
  }

  void pauseSession() {
    _timerService.cancelTimer();

    if (_state.phase == TimerPhase.prep) {
      _state = _state.copyWith(phase: TimerPhase.pausedPrep);
    } else if (_state.phase == TimerPhase.exam) {
      _state = _state.copyWith(phase: TimerPhase.pausedExam);
    } else if (_state.phase == TimerPhase.breakTime) {
      _state = _state.copyWith(phase: TimerPhase.pausedBreak);
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
      return;
    }

    if (_state.phase == TimerPhase.pausedBreak) {
      _state = _state.copyWith(phase: TimerPhase.breakTime);
      notifyListeners();
      _startBreakTicker();
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

  Future<void> finishSession({String? finishType, String? endType}) async {
    if (_state.phase != TimerPhase.exam && _state.phase != TimerPhase.pausedExam) {
      return;
    }

    await _completeCurrentQuestion(
      continueSequence: false,
      finishType: finishType,
      endType: endType,
    );
  }

  void resetSession() {
    _timerService.cancelTimer();
    _latestFinishedRecordId = null;
    _state = TimerSessionState.initial(
      plannedDurationSec: _state.plannedDurationSec,
      totalQuestions: _state.totalQuestions,
      breakDurationSec: _state.breakDurationSec,
    ).copyWith(records: _state.records);
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
      examRemaining: _state.plannedDurationSec,
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

        final nextRemaining = _state.examRemaining - 1;
        if (_state.isContinuousMode && nextRemaining <= 0) {
          _state = _state.copyWith(examRemaining: 0);
          notifyListeners();
          unawaited(_completeCurrentQuestion(continueSequence: true));
          return;
        }

        _state = _state.copyWith(examRemaining: nextRemaining);
        notifyListeners();

        if (nextRemaining == TimerConstants.twoMinuteWarningSeconds &&
            !_state.twoMinuteAlertShown) {
          _state = _state.copyWith(twoMinuteAlertShown: true);
          notifyListeners();
          onTwoMinuteAlert?.call();
          _timerService.playSound('warning.mp3');
        }
      },
    );
  }

  void _startBreakTicker() {
    _timerService.startPeriodic(
      duration: const Duration(seconds: 1),
      onTick: (_) {
        if (_state.phase != TimerPhase.breakTime) return;

        if (_state.breakRemaining > 1) {
          _state = _state.copyWith(breakRemaining: _state.breakRemaining - 1);
          notifyListeners();
          return;
        }

        _state = _state.copyWith(breakRemaining: 0);
        notifyListeners();
        _startPrepForCurrentQuestion();
      },
    );
  }

  void _startPrepForCurrentQuestion() {
    _timerService.cancelTimer();
    _state = TimerSessionState.initial(
      plannedDurationSec: _state.plannedDurationSec,
      totalQuestions: _state.totalQuestions,
      currentQuestion: _state.currentQuestion,
      breakDurationSec: _state.breakDurationSec,
    ).copyWith(
      phase: TimerPhase.prep,
      sessionExamName: _state.sessionExamName,
      sessionSubject: _state.sessionSubject,
      sessionTopic: _state.sessionTopic,
      records: _state.records,
    );
    notifyListeners();
    _startPrepTicker();
  }

  Future<void> _completeCurrentQuestion({
    required bool continueSequence,
    String? finishType,
    String? endType,
  }) async {
    _timerService.cancelTimer();
    _timerService.playSound('end.mp3');

    if (_state.phase == TimerPhase.exam ||
        _state.phase == TimerPhase.pausedExam) {
      _commitCurrentStageTime();
    }

    final record = _createRecord(
      finishType: finishType,
      endType: endType,
    );
    final updatedRecords = [record, ..._state.records];
    _latestFinishedRecordId = record.id;

    final hasNextQuestion = continueSequence &&
        _state.currentQuestion < _state.totalQuestions;

    if (!hasNextQuestion) {
      _state = _state.copyWith(
        phase: TimerPhase.finished,
        records: updatedRecords,
      );
      notifyListeners();
      await RecordStorage.saveRecords(_state.records);
      await onSessionFinished?.call(record);
      return;
    }

    final nextQuestion = _state.currentQuestion + 1;
    _state = TimerSessionState.initial(
      plannedDurationSec: _state.plannedDurationSec,
      totalQuestions: _state.totalQuestions,
      currentQuestion: nextQuestion,
      breakDurationSec: _state.breakDurationSec,
    ).copyWith(
      phase: _state.breakDurationSec > 0 ? TimerPhase.breakTime : TimerPhase.prep,
      breakRemaining: _state.breakDurationSec,
      sessionExamName: _state.sessionExamName,
      sessionSubject: _state.sessionSubject,
      sessionTopic: _state.sessionTopic,
      records: updatedRecords,
    );
    notifyListeners();

    await RecordStorage.saveRecords(_state.records);

    if (_state.phase == TimerPhase.breakTime) {
      _startBreakTicker();
    } else {
      _startPrepTicker();
    }
  }

  PracticeRecord _createRecord({
    String? finishType,
    String? endType,
  }) {
    final actualEndSec = _state.examElapsed;
    return PracticeRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      examName: _state.totalQuestions > 1
          ? '${_state.sessionExamName} ${_state.currentQuestion}번'
          : _state.sessionExamName,
      subject: _state.sessionSubject,
      topic: _state.totalQuestions > 1 ? _repeatedTopicLabel : _state.sessionTopic,
      date: DateTime.now(),
      plannedDurationSec: _state.plannedDurationSec,
      actualEndSec: actualEndSec,
      finishType: _resolveFinishType(
        finishType: finishType,
        endType: endType,
        actualEndSec: actualEndSec,
        plannedDurationSec: _state.plannedDurationSec,
      ),
      historySeconds: _state.stageSeconds[ExamStage.historyTaking] ?? 0,
      physicalSeconds: _state.stageSeconds[ExamStage.physicalExam] ?? 0,
      educationSeconds: _state.stageSeconds[ExamStage.patientEducation] ?? 0,
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

  String _resolveFinishType({
    String? finishType,
    String? endType,
    required int actualEndSec,
    required int plannedDurationSec,
  }) {
    if (actualEndSec >= plannedDurationSec) {
      return finishTypeOvertime;
    }

    final direct = finishType?.trim();
    if (direct == finishTypeEarly) {
      return finishTypeEarly;
    }

    return endType == null ? finishTypeEarly : finishTypeEarly;
  }

  String _resolveSessionTopic(
    String normalizedSubject,
    String? topic, {
    int? totalQuestions,
  }) {
    if ((totalQuestions ?? _state.totalQuestions) > 1) {
      return _repeatedTopicLabel;
    }
    return sanitizeTopicForSubject(normalizedSubject, topic);
  }

  void _updateExamDuration(int nextDurationSec) {
    if (_state.phase != TimerPhase.idle) {
      return;
    }

    final normalizedDuration = nextDurationSec < TimerConstants.minExamTotalSeconds
        ? TimerConstants.minExamTotalSeconds
        : nextDurationSec;
    if (normalizedDuration == _state.plannedDurationSec) {
      return;
    }

    _state = _state.copyWith(
      plannedDurationSec: normalizedDuration,
      examRemaining: normalizedDuration,
    );
    notifyListeners();
  }

  void _updateQuestionCount(int nextQuestionCount) {
    if (_state.phase != TimerPhase.idle) {
      return;
    }

    final normalizedQuestionCount = nextQuestionCount.clamp(
      TimerConstants.minContinuousQuestionCount,
      TimerConstants.maxContinuousQuestionCount,
    );
    if (normalizedQuestionCount == _state.totalQuestions) {
      return;
    }

    _state = _state.copyWith(
      totalQuestions: normalizedQuestionCount,
      currentQuestion: TimerConstants.minContinuousQuestionCount,
    );
    notifyListeners();
  }

  void _updateBreakDuration(int nextBreakDurationSec) {
    if (_state.phase != TimerPhase.idle) {
      return;
    }

    final normalizedBreakDuration = nextBreakDurationSec.clamp(
      0,
      TimerConstants.maxBreakSeconds,
    );
    if (normalizedBreakDuration == _state.breakDurationSec) {
      return;
    }

    _state = _state.copyWith(
      breakDurationSec: normalizedBreakDuration,
      breakRemaining: normalizedBreakDuration,
    );
    notifyListeners();
  }
}
