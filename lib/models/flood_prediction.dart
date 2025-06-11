// lib/models/flood_prediction.dart
class FloodPrediction {
  final String originalDistrict;
  final String matchedDistrict;
  final String floodRisk;

  FloodPrediction({
    required this.originalDistrict,
    required this.matchedDistrict,
    required this.floodRisk,
  });

  factory FloodPrediction.fromJson(Map<String, dynamic> json) {
    return FloodPrediction(
      originalDistrict: json['original_district'] ?? 'Unknown',
      matchedDistrict: json['matched_district'] ?? 'Unknown',
      floodRisk: json['flood_risk'] ?? 'Unknown',
    );
  }
}
