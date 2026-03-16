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
    required this.prepRemaining,
    required this.examRemaining,
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
  final int prepRemaining;
  final int examRemaining;
  final ExamStage? currentStage;
  final int examElapsedAtStageStart;
  final Map<ExamStage, int> stageSeconds;
  final List<PracticeRecord> records;
  final bool twoMinuteAlertShown;

  factory TimerSessionState.initial() {
    return TimerSessionState(
      phase: TimerPhase.idle,
      sessionExamName: defaultExamName,
      sessionSubject: defaultSubject,
      sessionTopic: defaultTopic,
      prepRemaining: TimerConstants.prepTotalSeconds,
      examRemaining: TimerConstants.examTotalSeconds,
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
    int? prepRemaining,
    int? examRemaining,
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
      prepRemaining: prepRemaining ?? this.prepRemaining,
      examRemaining: examRemaining ?? this.examRemaining,
      currentStage: clearCurrentStage
          ? null
          : currentStage ?? this.currentStage,
      examElapsedAtStageStart:
          examElapsedAtStageStart ?? this.examElapsedAtStageStart,
      stageSeconds: stageSeconds ?? this.stageSeconds,
      records: records ?? this.records,
      twoMinuteAlertShown: twoMinuteAlertShown ?? this.twoMinuteAlertShown,
    );
  }

  int get examElapsed => TimerConstants.examTotalSeconds - examRemaining;
  int get overtimeSeconds => examRemaining < 0 ? -examRemaining : 0;
  bool get isOvertime => examElapsed > TimerConstants.examTotalSeconds;

  bool get isRunning => phase == TimerPhase.prep || phase == TimerPhase.exam;

  bool get isPaused =>
      phase == TimerPhase.pausedPrep || phase == TimerPhase.pausedExam;

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
        if (examRemaining <= TimerConstants.twoMinuteWarningSeconds) {
          return '2분 전';
        }
        return '세션 진행 중';
      case TimerPhase.pausedPrep:
        return '준비 시간 일시정지';
      case TimerPhase.pausedExam:
        return isOvertime ? '시간 초과 일시정지' : '세션 일시정지';
      case TimerPhase.finished:
        return '세션 종료';
    }
  }
}
