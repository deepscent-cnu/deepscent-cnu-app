import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/correct_scent.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/round_log.dart';
import 'package:get/get.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/question_bank.dart';

class NormalOlfactoryTrainingController extends GetxController {
  var currentRound = 1.obs;
  var selectedOption = '';
  var timeTaken = 0;
  var totalScore = 0;
  var totalTimeTaken = 0;

  //기존 라운드
  // final totalRounds = 4;
  //현재는 2문항 -> 12문항으로
  int get totalRounds => normalTrainingQuestionBank.length;


  var logs = <RoundLog>[].obs;

  //기존
  // var correctScentList = <CorrectScent>[].obs;
  //수정
  /// ✅ 현재 라운드의 문항
  ScentQuestion get currentQuestion =>
      normalTrainingQuestionBank[currentRound.value - 1];

  /// ✅ 현재 라운드의 정답(분사향 정보 포함)
  CorrectScent getCorrectScentByRound() => currentQuestion.correct;

  /// ✅ 현재 라운드의 4지선다 보기(고정)
  List<String> getCurrentOptions() => currentQuestion.options;

  bool getIsCorrect() => currentQuestion.correct.scentName == selectedOption;

//기존
//
//   void addLog(int scentStrength) {
//     //기존
//     // String correctOption = correctScentList[currentRound.value - 1].scentName;
//
//     final correctOption = currentQuestion.correct.scentName;
//     logs.add(
//       RoundLog(
//         correctOption: correctOption,
//         selectedOption: selectedOption,
//         isCorrect: correctOption == selectedOption,
//         timeTaken: timeTaken,
//         scentStrength: scentStrength,
//       ),
//     );
//     //수정
//     // 점수/총시간 누적을 여기서 할지, 결과 화면에서 할지 선택
//     totalTimeTaken += timeTaken;
//     if (correctOption == selectedOption) totalScore += 1;
//   }
  //수정
  void addLog([int scentStrength = -1]) {
    final correctOption = currentQuestion.correct.scentName;

    logs.add(
      RoundLog(
        correctOption: correctOption,
        selectedOption: selectedOption,
        isCorrect: correctOption == selectedOption,
        timeTaken: timeTaken,
        scentStrength: scentStrength, // 강도 미수집이면 -1
      ),
    );

    totalTimeTaken += timeTaken;
    if (correctOption == selectedOption) totalScore += 1;
  }



  //기존
  // void addCorrectScentList(List<CorrectScent> correctScentList) {
  //   for (CorrectScent correctScent in correctScentList) {
  //     this.correctScentList.add(correctScent);
  //   }
  // }
  //
  // CorrectScent getCorrectScentByRound() {
  //   return correctScentList[currentRound.value - 1];
  // }
  //
  // bool getIsCorrect() {
  //   return correctScentList[currentRound.value - 1].scentName == selectedOption;
  // }



  /// ✅ 다음 라운드로 이동 (최대 12)
  void nextRound() {
    if (currentRound.value < totalRounds) {
      currentRound.value += 1;
    }
  }

  void reset() {
    currentRound.value = 1;
    selectedOption = '';
    timeTaken = 0;
    totalScore = 0;
    totalTimeTaken = 0;
    logs.clear();
    //기존
    // correctScentList.clear();
  }

  void resetRound() {
    selectedOption = '';
    timeTaken = 0;
  }
}
