class SensorData {
  final String deviceId;
  final double temperature;
  final double soilHum; // Changed from humidity to soilHum
  final double ph;
  final double tds; // Changed from ec to tds
  final int waterLevel;
  final bool pumpWater; // Added for water pump
  final bool pumpNutrient; // Added for nutrient pump

  SensorData({
    required this.deviceId,
    required this.temperature,
    required this.soilHum,
    required this.ph,
    required this.tds,
    required this.waterLevel,
    required this.pumpWater,
    required this.pumpNutrient,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      deviceId: json['device_id'] ?? 'hydro_001',
      temperature: (json['temperature'] ?? 0).toDouble(),
      soilHum: (json['soilHum'] ?? 0).toDouble(), // Changed key
      ph: (json['ph'] ?? 0).toDouble(),
      tds: (json['tds'] ?? 0).toDouble(), // Changed key
      waterLevel: (json['waterLevel'] ?? 0),
      pumpWater: (json['pumpWater'] ?? false), // New field
      pumpNutrient: (json['pumpNutrient'] ?? false), // New field
    );
  }

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'temperature': temperature,
        'soilHum': soilHum,
        'ph': ph,
        'tds': tds,
        'waterLevel': waterLevel,
        'pumpWater': pumpWater,
        'pumpNutrient': pumpNutrient,
      };

  SensorData copyWith({
    String? deviceId,
    double? temperature,
    double? soilHum,
    double? ph,
    double? tds,
    int? waterLevel,
    bool? pumpWater,
    bool? pumpNutrient,
  }) {
    return SensorData(
      deviceId: deviceId ?? this.deviceId,
      temperature: temperature ?? this.temperature,
      soilHum: soilHum ?? this.soilHum,
      ph: ph ?? this.ph,
      tds: tds ?? this.tds,
      waterLevel: waterLevel ?? this.waterLevel,
      pumpWater: pumpWater ?? this.pumpWater,
      pumpNutrient: pumpNutrient ?? this.pumpNutrient,
    );
  }
}