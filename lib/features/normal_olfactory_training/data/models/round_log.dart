class RoundLog {
  final String correctOption;
  final String selectedOption;
  final bool isCorrect;
  final int timeTaken;

  RoundLog({
    required this.correctOption,
    required this.selectedOption,
    required this.isCorrect,
    required this.timeTaken,
  });

   Map<String, dynamic> toJson() {
    return {
      'correctOption': correctOption,
      'selectedOption': selectedOption,
      'isCorrect': isCorrect,
      'timeTaken': timeTaken,
    };
  }
}