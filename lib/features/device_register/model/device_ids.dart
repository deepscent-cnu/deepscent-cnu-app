class DeviceIds {
  final String? deviceId1;
  final String? deviceId2;
  final String? deviceId3;

  DeviceIds({
    required this.deviceId1,
    required this.deviceId2,
    required this.deviceId3,
  });

  factory DeviceIds.fromJson(Map<String, dynamic> json) {
    return DeviceIds(deviceId1: json['deviceId1'], deviceId2: json['deviceId2'], deviceId3: json['deviceId3']);
  }
}
