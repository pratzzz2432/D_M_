// lib/models/earthquake_prediction.dart
class EarthquakePrediction {
  final List<HighRiskCity> highRiskCities;
  final String readMoreUrl;

  EarthquakePrediction({
    required this.highRiskCities,
    required this.readMoreUrl,
  });

  factory EarthquakePrediction.fromJson(Map<String, dynamic> json) {
    var citiesList = json['high_risk_cities'] as List?;
    List<HighRiskCity> cities = citiesList != null
        ? citiesList.map((i) => HighRiskCity.fromJson(i)).toList()
        : [];

    return EarthquakePrediction(
      highRiskCities: cities,
      readMoreUrl: json['read_more_url'] ?? '',
    );
  }
}

class HighRiskCity {
  final String city;
  final String state;
  final double magnitude;

  HighRiskCity({
    required this.city,
    required this.state,
    required this.magnitude,
  });

  factory HighRiskCity.fromJson(Map<String, dynamic> json) {
    return HighRiskCity(
      city: json['city'] ?? 'Unknown',
      state: json['state'] ?? 'Unknown',
      magnitude: (json['magnitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
