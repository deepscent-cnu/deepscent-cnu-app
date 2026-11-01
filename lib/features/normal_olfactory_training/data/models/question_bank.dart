import 'correct_scent.dart';

class ScentQuestion {
  final int id;
  final CorrectScent correct;
  final List<String> options;

  const ScentQuestion({
    required this.id,
    required this.correct,
    required this.options,
  }) : assert(options.length == 4);
}

final List<ScentQuestion> normalTrainingQuestionBank = [
  ScentQuestion(
    id: 1,
    correct: CorrectScent(scentName: '베이비파우더', deviceNumber: 3, fanNumber: 1),
    options: ['베이비파우더', '사과', '카레', '초콜릿'],
  ),
  ScentQuestion(
    id: 2,
    correct: CorrectScent(scentName: '계피', deviceNumber: 2, fanNumber: 1),
    options: ['딸기', '꽃', '계피', '레몬'],
  ),
  ScentQuestion(
    id: 3,
    correct: CorrectScent(scentName: '복숭아', deviceNumber: 1, fanNumber: 1),
    options: ['인삼', '수박', '복숭아', '땅콩'],
  ),
  ScentQuestion(
    id: 4,
    correct: CorrectScent(scentName: '누룽지', deviceNumber: 3, fanNumber: 2),
    options: ['자두', '멜론', '누룽지', '아카시아'],
  ),
  ScentQuestion(
    id: 5,
    correct: CorrectScent(scentName: '박하', deviceNumber: 2, fanNumber: 2),
    options: ['박하', '사과', '오렌지', '나무'],
  ),
  ScentQuestion(
    id: 6,
    correct: CorrectScent(scentName: '초콜릿', deviceNumber: 1, fanNumber: 2),
    options: ['초콜릿', '쑥', '마늘', '포도'],
  ),
  ScentQuestion(
    id: 7,
    correct: CorrectScent(scentName: '한약', deviceNumber: 3, fanNumber: 3),
    options: ['딸기', '포도', '한약', '김치'],
  ),
  ScentQuestion(
    id: 8,
    correct: CorrectScent(scentName: '파스', deviceNumber: 2, fanNumber: 3),
    options: ['파스', '체리', '초콜릿', '꽃'],
  ),
  ScentQuestion(
    id: 9,
    correct: CorrectScent(scentName: '홍삼', deviceNumber: 1, fanNumber: 3),
    options: ['솜사탕', '꿀', '홍삼', '김치'],
  ),
  ScentQuestion(
    id: 10,
    correct: CorrectScent(scentName: '유자', deviceNumber: 2, fanNumber: 4),
    options: ['옥수수', '레몬', '유자', '비누'],
  ),
  ScentQuestion(
    id: 11,
    correct: CorrectScent(scentName: '장미', deviceNumber: 3, fanNumber: 4),
    options: ['자몽', '소나무', '커피', '장미'],
  ),
  ScentQuestion(
    id: 12,
    correct: CorrectScent(scentName: '소나무', deviceNumber: 1, fanNumber: 4),
    options: ['멜론', '생강', '바나나', '소나무'],
  ),
];
