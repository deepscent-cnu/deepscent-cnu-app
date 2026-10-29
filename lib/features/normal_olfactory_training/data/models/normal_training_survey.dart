class NormalTrainingSurveyQuestion {
  const NormalTrainingSurveyQuestion({
    required this.key,
    required this.question,
    required this.options,
  });

  final String key;
  final String question;
  final List<String> options;
}

const normalTrainingSurveyQuestions = <NormalTrainingSurveyQuestion>[
  NormalTrainingSurveyQuestion(
    key: 'gender',
    question: '성별을 선택해주세요.',
    options: ['남성', '여성'],
  ),
  NormalTrainingSurveyQuestion(
    key: 'education_level',
    question: '최종 교육수준을 선택해주세요.',
    options: ['무학', '초등학교 졸업', '중학교 졸업', '고등학교 졸업', '대학교 졸업', '대학원 졸업 이상'],
  ),
  NormalTrainingSurveyQuestion(
    key: 'living_arrangement',
    question: '현재 주거형태를 선택해주세요.',
    options: ['혼자 거주', '배우자와 거주', '자녀 또는 가족과 거주', '시설 또는 공동생활', '기타'],
  ),
  NormalTrainingSurveyQuestion(
    key: 'occupation_status',
    question: '현재 직업이 있습니까?',
    options: ['있음', '없음'],
  ),
  NormalTrainingSurveyQuestion(
    key: 'occupation_detail',
    question: '현재 직업을 입력해주세요.',
    options: [],
  ),
  NormalTrainingSurveyQuestion(
    key: 'nasal_condition',
    question: '현재 감기, 비염 또는 축농증 증상이 있습니까?',
    options: ['예', '아니오'],
  ),
  NormalTrainingSurveyQuestion(
    key: 'olfactory_difficulty',
    question: '평소 냄새를 맡기 어렵거나 후각이 저하되었다고 느낍니까?',
    options: ['예', '아니오'],
  ),
  NormalTrainingSurveyQuestion(
    key: 'scent_reaction',
    question: '특정 향을 맡았을 때 알레르기, 두통, 어지럼 또는 메스꺼움을 경험한 적이 있습니까?',
    options: ['예', '아니오'],
  ),
  NormalTrainingSurveyQuestion(
    key: 'smoking',
    question: '현재 흡연 중입니까?',
    options: ['예', '아니오'],
  ),
];
