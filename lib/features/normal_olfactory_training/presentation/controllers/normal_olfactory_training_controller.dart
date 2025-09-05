import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/correct_scent.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/round_log.dart';
import 'package:get/get.dart';

class NormalOlfactoryTrainingController extends GetxController {
  var currentRound = 1.obs;
  var selectedOption = '';
  var timeTaken = 0;
  var totalScore = 0;
  var totalTimeTaken = 0;
  final totalRounds = 4;

  var logs = <RoundLog>[].obs;
  var correctScentList = <CorrectScent>[].obs;

  void addLog(int scentStrength) {
    String correctOption = correctScentList[currentRound.value - 1].scentName;
    logs.add(
      RoundLog(
        correctOption: correctOption,
        selectedOption: selectedOption,
        isCorrect: correctOption == selectedOption,
        timeTaken: timeTaken,
        scentStrength: scentStrength,
      ),
    );
  }

  void addCorrectScentList(List<CorrectScent> correctScentList) {
    for (CorrectScent correctScent in correctScentList) {
      this.correctScentList.add(correctScent);
    }
  }

  CorrectScent getCorrectScentByRound() {
    return correctScentList[currentRound.value - 1];
  }

  bool getIsCorrect() {
    return correctScentList[currentRound.value - 1].scentName == selectedOption;
  }

  void reset() {
    currentRound.value = 1;
    selectedOption = '';
    timeTaken = 0;
    totalScore = 0;
    totalTimeTaken = 0;
    logs.clear();
    correctScentList.clear();
  }

  void resetRound() {
    selectedOption = '';
    timeTaken = 0;
  }
}
