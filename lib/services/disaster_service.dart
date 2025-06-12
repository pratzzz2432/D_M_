import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:d_m/app/data/models/flood_prediction_response.dart';
import 'package:d_m/app/data/models/cyclone_prediction_response.dart';
import 'package:d_m/app/data/models/earthquake_prediction_response.dart';

class DisasterService {
  static const String _floodApiBaseUrl =
      'https://flood-api-756506665902.us-central1.run.app';
  static const String _cycloneApiBaseUrl =
      'https://cyclone-api-756506665902.asia-south1.run.app';
  // Note: The issue mentions '/docs' for earthquake, but the curl example doesn't. Using the base URL as per the curl.
  static const String _earthquakeApiUrl =
      'https://my-fastapi-app-wwb655aqwa-uc.a.run.app/';

  Future<FloodPredictionResponse> getFloodPrediction(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse('$_floodApiBaseUrl/predict');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'lat': lat, 'lon': lon}),
      );

      if (response.statusCode == 200) {
        return FloodPredictionResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Flood API Error: ${response.statusCode} ${response.body}');
        throw Exception(
          'Failed to load flood prediction. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Flood API Exception: $e');
      throw Exception('Failed to load flood prediction: $e');
    }
  }

  Future<CyclonePredictionResponse> getCyclonePrediction(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse('$_cycloneApiBaseUrl/predict');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'lat': lat, 'lon': lon}),
      );

      if (response.statusCode == 200) {
        return CyclonePredictionResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Cyclone API Error: ${response.statusCode} ${response.body}');
        throw Exception(
          'Failed to load cyclone prediction. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Cyclone API Exception: $e');
      throw Exception('Failed to load cyclone prediction: $e');
    }
  }

  Future<EarthquakePredictionResponse> getEarthquakePrediction() async {
    final url = Uri.parse(_earthquakeApiUrl);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return EarthquakePredictionResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Earthquake API Error: ${response.statusCode} ${response.body}');
        throw Exception(
          'Failed to load earthquake prediction. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Earthquake API Exception: $e');
      throw Exception('Failed to load earthquake prediction: $e');
    }
  }
}
