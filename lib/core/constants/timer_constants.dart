// CPX 타이머에서 공통으로 사용하는 시간 관련 상수를 모아둔다.
class TimerConstants {
  static const int prepTotalSeconds = 60;
  static const int examTotalSeconds = 12 * 60;
  static const int examAdjustmentStepSeconds = 30;
  static const int minExamTotalSeconds = 30;
  static const int twoMinuteWarningSeconds = 120;
  static const int minContinuousQuestionCount = 1;
  static const int maxContinuousQuestionCount = 10;
  static const int breakAdjustmentStepSeconds = 10;
  static const int maxBreakSeconds = 10 * 60;

  const TimerConstants._();
}
