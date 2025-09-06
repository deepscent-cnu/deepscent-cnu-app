class ScentInfo {
  final String scentName;
  final int deviceNumber;
  final int fanNumber;

  ScentInfo({
    required this.scentName,
    required this.deviceNumber,
    required this.fanNumber,
  });

  factory ScentInfo.fromJson(Map<String, dynamic> json) {
    return ScentInfo(
      scentName: json['scentName'],
      deviceNumber: json['deviceNumber'],
      fanNumber: json['fanNumber'],
    );
  }
}
