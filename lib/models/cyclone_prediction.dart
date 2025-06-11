// lib/models/cyclone_prediction.dart
class CyclonePrediction {
  final String timestampUtc;
  final CycloneLocation location;
  final CycloneWeatherData weatherData;
  final String cycloneCondition;

  CyclonePrediction({
    required this.timestampUtc,
    required this.location,
    required this.weatherData,
    required this.cycloneCondition,
  });

  factory CyclonePrediction.fromJson(Map<String, dynamic> json) {
    return CyclonePrediction(
      timestampUtc: json['timestamp_utc'] ?? '',
      location: CycloneLocation.fromJson(json['location'] ?? {}),
      weatherData: CycloneWeatherData.fromJson(json['weather_data'] ?? {}),
      cycloneCondition: json['cyclone_condition'] ?? 'Unknown',
    );
  }
}

class CycloneLocation {
  final double latitude;
  final double longitude;
  final String district;

  CycloneLocation({
    required this.latitude,
    required this.longitude,
    required this.district,
  });

  factory CycloneLocation.fromJson(Map<String, dynamic> json) {
    return CycloneLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      district: json['district'] ?? 'Unknown',
    );
  }
}

class CycloneWeatherData {
  final double usaWind;
  final int usaPres; // Assuming pressure is an integer
  final int stormSpeed;
  final int stormDir;
  final int month;

  CycloneWeatherData({
    required this.usaWind,
    required this.usaPres,
    required this.stormSpeed,
    required this.stormDir,
    required this.month,
  });

  factory CycloneWeatherData.fromJson(Map<String, dynamic> json) {
    return CycloneWeatherData(
      usaWind: (json['usa_wind'] as num?)?.toDouble() ?? 0.0,
      usaPres: (json['usa_pres'] as num?)?.toInt() ?? 0,
      stormSpeed: (json['storm_speed'] as num?)?.toInt() ?? 0,
      stormDir: (json['storm_dir'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 0,
    );
  }
}
