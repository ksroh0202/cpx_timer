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
