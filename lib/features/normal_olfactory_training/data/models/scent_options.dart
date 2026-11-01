class ScentOptions {
  final String correctOption;
  final String scentOption1;
  final String scentOption2;
  final String scentOption3;
  final String scentOption4;

  ScentOptions({
    required this.correctOption,
    required this.scentOption1,
    required this.scentOption2,
    required this.scentOption3,
    required this.scentOption4,
  });

  factory ScentOptions.fromJson(Map<String, dynamic> json) {
    return ScentOptions(
      correctOption: json['correctOption'],
      scentOption1: json['scentOption1'],
      scentOption2: json['scentOption2'],
      scentOption3: json['scentOption3'],
      scentOption4: json['scentOption4'],
    );
  }
}
