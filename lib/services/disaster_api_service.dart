// lib/services/disaster_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flood_prediction.dart';
import '../models/cyclone_prediction.dart';
import '../models/earthquake_prediction.dart';

class DisasterApiService {
  static const String _floodApiUrl = "https://flood-api-756506665902.us-central1.run.app/predict";
  static const String _cycloneApiUrl = "https://cyclone-api-756506665902.asia-south1.run.app/predict";
  static const String _earthquakeApiUrl = "https://my-python-app-wwb655aqwa-uc.a.run.app/"; // Remember to add /docs if that's the actual endpoint for GET

  Future<FloodPrediction?> getFloodPrediction(double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse(_floodApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"lat": lat, "lon": lon}),
      );

      if (response.statusCode == 200) {
        return FloodPrediction.fromJson(jsonDecode(response.body));
      } else {
        print("Flood API Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Flood API Exception: $e");
      return null;
    }
  }

  Future<CyclonePrediction?> getCyclonePrediction(double lat, double lon) async {
    try {
      final response = await http.post(
        Uri.parse(_cycloneApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"lat": lat, "lon": lon}),
      );

      if (response.statusCode == 200) {
        return CyclonePrediction.fromJson(jsonDecode(response.body));
      } else {
        print("Cyclone API Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Cyclone API Exception: $e");
      return null;
    }
  }

  Future<EarthquakePrediction?> getEarthquakePrediction() async {
    // Note: The user mentioned the earthquake URL as 'https://my-python-app-wwb655aqwa-uc.a.run.app/ docs'
    // Assuming the actual API endpoint for GET request is 'https://my-python-app-wwb655aqwa-uc.a.run.app/'
    // and '/docs' is for documentation. If '/docs' is part of the GET URL, it should be included.
    // For now, using the base URL.
    try {
      final response = await http.get(Uri.parse(_earthquakeApiUrl));

      if (response.statusCode == 200) {
        return EarthquakePrediction.fromJson(jsonDecode(response.body));
      } else {
        print("Earthquake API Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Earthquake API Exception: $e");
      return null;
    }
  }
}
