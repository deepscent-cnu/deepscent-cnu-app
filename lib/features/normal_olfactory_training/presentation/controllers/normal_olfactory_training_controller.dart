import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/round_log.dart';
import 'package:get/get.dart';

class NormalOlfactoryTrainingController extends GetxController {
  var currentRound = 1.obs;
  var correctOption = '';
  var selectedOption = '';
  var isCorrect = false;
  var timeTaken = 0;
  var totalScore = 0;
  var totalTimeTaken = 0;
  final totalRounds = 4;

  var logs = <RoundLog>[].obs;

  void addLog(int scentStrength) {
    logs.add(
      RoundLog(
        correctOption: correctOption,
        selectedOption: selectedOption,
        isCorrect: isCorrect,
        timeTaken: timeTaken,
        scentStrength: scentStrength,
      ),
    );
  }

  void reset() {
    currentRound.value = 1;
    correctOption = '';
    selectedOption = '';
    isCorrect = false;
    timeTaken = 0;
    totalScore = 0;
    totalTimeTaken = 0;
    logs.clear();
  }

  void resetRound() {
    correctOption = '';
    selectedOption = '';
    isCorrect = false;
    timeTaken = 0;
  }
}
