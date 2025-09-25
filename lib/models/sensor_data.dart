class SensorData {
  final String deviceId;
  final double temperature;
  final double humidity;
  final double ph;
  final double ec;
  final int waterLevel;
  final bool pumpOn;

  SensorData({
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.ec,
    required this.waterLevel,
    required this.pumpOn,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      deviceId: json['device_id'],
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
      ec: (json['ec'] ?? 0).toDouble(),
      waterLevel: (json['waterLevel'] ?? 0),
      pumpOn: (json['pumpOn'] ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'temperature': temperature,
        'humidity': humidity,
        'ph': ph,
        'ec': ec,
        'waterLevel': waterLevel,
        'pumpOn': pumpOn,
      };

  // Tambahkan copyWith
  SensorData copyWith({
    String? deviceId,
    double? temperature,
    double? humidity,
    double? ph,
    double? ec,
    int? waterLevel,
    bool? pumpOn,
  }) {
    return SensorData(
      deviceId: deviceId ?? this.deviceId,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      ph: ph ?? this.ph,
      ec: ec ?? this.ec,
      waterLevel: waterLevel ?? this.waterLevel,
      pumpOn: pumpOn ?? this.pumpOn,
    );
  }
}
