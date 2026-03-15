const String defaultExamName = '이름 없는 연습';
const String defaultSubject = '기타';
const String defaultTopic = '기타';

const List<String> examSubjects = [
  '소화기',
  '순환기',
  '호흡기',
  '신장/비뇨',
  '전신',
  '근골격계',
  '정신/신경',
  '여성/소아',
  '상담',
  '기타',
];

const Map<String, List<String>> examTopicsBySubject = {
  '소화기': [
    '복통',
    '소화불량',
    '속쓰림',
    '구토',
    '변비',
    '설사',
    '혈변',
    '기타',
  ],
  '순환기': [
    '가슴통증',
    '두근거림',
    '호흡곤란',
    '실신',
    '부종',
    '기타',
  ],
  '호흡기': [
    '기침',
    '가래',
    '객혈',
    '호흡곤란',
    '흉통',
    '기타',
  ],
  '신장/비뇨': [
    '배뇨통',
    '혈뇨',
    '빈뇨',
    '다뇨',
    '옆구리 통증',
    '기타',
  ],
  '전신': [
    '발열',
    '피로',
    '체중감소',
    '체중증가',
    '부종',
    '기타',
  ],
  '근골격계': [
    '관절통',
    '근육통',
    '허리통증',
    '어깨통증',
    '목통증',
    '기타',
  ],
  '정신/신경': [
    '두통',
    '어지럼',
    '기억력 저하',
    '불안',
    '우울감',
    '수면장애',
    '이상 감각',
    '기타',
  ],
  '여성/소아': [
    '월경 이상',
    '질분비물',
    '복부 불편감',
    '소아 발열',
    '예방접종 상담',
    '기타',
  ],
  '상담': [
    '금연',
    '금주',
    '체중조절',
    '운동 상담',
    '복약 상담',
    '기타',
  ],
  '기타': ['기타'],
};

String sanitizeExamName(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? defaultExamName : trimmed;
}

String sanitizeSubject(String? value) {
  if (value != null && examSubjects.contains(value)) {
    return value;
  }
  return defaultSubject;
}

List<String> topicsForSubject(String? subject) {
  final normalizedSubject = sanitizeSubject(subject);
  return examTopicsBySubject[normalizedSubject] ?? const [defaultTopic];
}

String sanitizeTopicForSubject(String? subject, String? topic) {
  final trimmed = topic?.trim() ?? '';
  final availableTopics = topicsForSubject(subject);
  if (trimmed.isEmpty || !availableTopics.contains(trimmed)) {
    return defaultTopic;
  }
  return trimmed;
}
