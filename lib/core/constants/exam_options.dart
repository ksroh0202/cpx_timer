const String defaultExamName = '이름 없는 연습';
const String defaultSubject = '기타';
const String defaultTopic = '기타';

const List<String> examSubjects = [
  '소화기',
  '순환기',
  '호흡기',
  '신장/비뇨',
  '전신',
  '관절/근골격/피부',
  '정신/신경',
  '산부/여성/소아',
  '상담',
  '기타',
];

const Map<String, List<String>> examTopicsBySubject = {
  '소화기': ['급성복통', '소화불량/만성복통', '토혈', '혈변', '구토', '변비', '설사', '황달', '기타'],
  '순환기': ['가슴통증', '실신', '두근거림', '고혈압', '이상지질혈증', '기타'],
  '호흡기': ['기침', '콧물/코막힘', '객혈', '호흡곤란', '기타'],
  '신장/비뇨': ['소변량변화(다뇨/핍뇨)', '혈뇨', '배뇨이상/요실금', '기타'],
  '전신': ['발열', '쉽게 멍이 듦', '피로', '체중감소', '체중증가', '기타'],
  '관절/근골격/피부': ['관절통증/부기', '목통증/허리통증', '피부발진', '기타'],
  '정신/신경': [
    '기분변화',
    '불안',
    '수면장애',
    '기억력저하',
    '어지럼',
    '두통',
    '경련',
    '근력/감각이상',
    '의식장애',
    '떨림/운동이상',
    '기타',
  ],
  '산부/여성/소아': [
    '유방통',
    '유방덩이',
    '질출혈',
    '질분비물',
    '예방접종',
    '성장/발달지연',
    '산전진찰',
    '월경통',
    '월경이상(무월경)',
    '기타',
  ],
  '상담': ['금주/금연', '물질오남용', '나쁜소식전하기', '가정폭력', '성폭력', '자살', '기타'],
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
