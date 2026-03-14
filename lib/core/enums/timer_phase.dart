// 타이머 세션의 전체 진행 상태를 정의한다.
enum TimerPhase {
  idle,
  prep,
  exam,
  pausedPrep,
  pausedExam,
  finished,
}
