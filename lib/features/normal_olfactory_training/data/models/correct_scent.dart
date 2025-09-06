class CorrectScent {
  final String scentName;
  final int deviceNumber;
  final int fanNumber;

  CorrectScent({
    required this.scentName,
    required this.deviceNumber,
    required this.fanNumber,
  });

  factory CorrectScent.fromJson(Map<String, dynamic> json) {
    return CorrectScent(
      scentName: json['scentName'],
      deviceNumber: json['deviceNumber'],
      fanNumber: json['fanNumber'],
    );
  }
}
