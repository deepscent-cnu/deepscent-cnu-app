import 'package:get/get.dart';

class NormalOlfactoryTrainingController extends GetxController {
  var currentRound = 1.obs;
  final totalRounds = 4;

  var logs = <RoundLog>[].obs;
}

class RoundLog {
  final String correctScent;
  final String selectedScent;
  final int timeTaken;

  RoundLog({
    required this.correctScent,
    required this.selectedScent,
    required this.timeTaken,
  });
}