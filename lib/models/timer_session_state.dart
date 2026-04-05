import '../core/constants/exam_options.dart';
import '../core/constants/timer_constants.dart';
import '../core/enums/exam_stage.dart';
import '../core/enums/timer_phase.dart';
import 'practice_record.dart';

class TimerSessionState {
  const TimerSessionState({
    required this.phase,
    required this.sessionExamName,
    required this.sessionSubject,
    required this.sessionTopic,
    required this.plannedDurationSec,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.breakDurationSec,
    required this.prepRemaining,
    required this.examRemaining,
    required this.breakRemaining,
    required this.currentStage,
    required this.examElapsedAtStageStart,
    required this.stageSeconds,
    required this.records,
    required this.twoMinuteAlertShown,
  });

  final TimerPhase phase;
  final String sessionExamName;
  final String sessionSubject;
  final String sessionTopic;
  final int plannedDurationSec;
  final int totalQuestions;
  final int currentQuestion;
  final int breakDurationSec;
  final int prepRemaining;
  final int examRemaining;
  final int breakRemaining;
  final ExamStage? currentStage;
  final int examElapsedAtStageStart;
  final Map<ExamStage, int> stageSeconds;
  final List<PracticeRecord> records;
  final bool twoMinuteAlertShown;

  factory TimerSessionState.initial({
    int plannedDurationSec = TimerConstants.examTotalSeconds,
    int totalQuestions = TimerConstants.minContinuousQuestionCount,
    int currentQuestion = TimerConstants.minContinuousQuestionCount,
    int breakDurationSec = 0,
  }) {
    return TimerSessionState(
      phase: TimerPhase.idle,
      sessionExamName: defaultExamName,
      sessionSubject: defaultSubject,
      sessionTopic: defaultTopic,
      plannedDurationSec: plannedDurationSec,
      totalQuestions: totalQuestions,
      currentQuestion: currentQuestion,
      breakDurationSec: breakDurationSec,
      prepRemaining: TimerConstants.prepTotalSeconds,
      examRemaining: plannedDurationSec,
      breakRemaining: breakDurationSec,
      currentStage: null,
      examElapsedAtStageStart: 0,
      stageSeconds: {for (final stage in ExamStage.values) stage: 0},
      records: const [],
      twoMinuteAlertShown: false,
    );
  }

  TimerSessionState copyWith({
    TimerPhase? phase,
    String? sessionExamName,
    String? sessionSubject,
    String? sessionTopic,
    int? plannedDurationSec,
    int? totalQuestions,
    int? currentQuestion,
    int? breakDurationSec,
    int? prepRemaining,
    int? examRemaining,
    int? breakRemaining,
    ExamStage? currentStage,
    bool clearCurrentStage = false,
    int? examElapsedAtStageStart,
    Map<ExamStage, int>? stageSeconds,
    List<PracticeRecord>? records,
    bool? twoMinuteAlertShown,
  }) {
    return TimerSessionState(
      phase: phase ?? this.phase,
      sessionExamName: sessionExamName ?? this.sessionExamName,
      sessionSubject: sessionSubject ?? this.sessionSubject,
      sessionTopic: sessionTopic ?? this.sessionTopic,
      plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      breakDurationSec: breakDurationSec ?? this.breakDurationSec,
      prepRemaining: prepRemaining ?? this.prepRemaining,
      examRemaining: examRemaining ?? this.examRemaining,
      breakRemaining: breakRemaining ?? this.breakRemaining,
      currentStage: clearCurrentStage ? null : currentStage ?? this.currentStage,
      examElapsedAtStageStart:
          examElapsedAtStageStart ?? this.examElapsedAtStageStart,
      stageSeconds: stageSeconds ?? this.stageSeconds,
      records: records ?? this.records,
      twoMinuteAlertShown: twoMinuteAlertShown ?? this.twoMinuteAlertShown,
    );
  }

  int get examElapsed => plannedDurationSec - examRemaining;
  int get overtimeSeconds => examRemaining < 0 ? -examRemaining : 0;
  bool get isOvertime => examElapsed > plannedDurationSec;
  bool get isContinuousMode => totalQuestions > 1;

  bool get isRunning =>
      phase == TimerPhase.prep ||
      phase == TimerPhase.exam ||
      phase == TimerPhase.breakTime;

  bool get isPaused =>
      phase == TimerPhase.pausedPrep ||
      phase == TimerPhase.pausedExam ||
      phase == TimerPhase.pausedBreak;

  bool get isExamActive =>
      phase == TimerPhase.exam || phase == TimerPhase.pausedExam;

  String get statusText {
    switch (phase) {
      case TimerPhase.idle:
        return '대기';
      case TimerPhase.prep:
        return '준비 시간';
      case TimerPhase.exam:
        if (isOvertime) {
          return '시간 초과';
        }
        if (plannedDurationSec > TimerConstants.twoMinuteWarningSeconds &&
            examRemaining <= TimerConstants.twoMinuteWarningSeconds) {
          return '2분 전';
        }
        return '시험 진행 중';
      case TimerPhase.breakTime:
        return '중간 휴식';
      case TimerPhase.pausedPrep:
        return '준비 시간 일시정지';
      case TimerPhase.pausedExam:
        return isOvertime ? '시간 초과 일시정지' : '시험 일시정지';
      case TimerPhase.pausedBreak:
        return '휴식 일시정지';
      case TimerPhase.finished:
        return '세션 종료';
    }
  }
}
