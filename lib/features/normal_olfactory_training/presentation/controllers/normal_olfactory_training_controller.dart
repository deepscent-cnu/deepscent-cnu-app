import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/round_log.dart';
import 'package:get/get.dart';

class NormalOlfactoryTrainingController extends GetxController {
  var currentRound = 1.obs;
  var correctOption = '';
  var isCorrect = false;
  var totalScore = 0;
  var totalTimeTaken = 0;
  final totalRounds = 4;

  var logs = <RoundLog>[].obs;

  void reset() {
    currentRound.value = 1;
    correctOption = '';
    isCorrect = false;
    totalScore = 0;
    totalTimeTaken = 0;
    logs.clear();
  }
}
