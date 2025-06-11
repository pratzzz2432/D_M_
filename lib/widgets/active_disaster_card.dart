// lib/widgets/active_disaster_card.dart
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/disaster_api_service.dart';
import '../models/flood_prediction.dart';
import '../models/cyclone_prediction.dart';
import '../models/earthquake_prediction.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ActiveDisasterCard extends StatefulWidget {
  const ActiveDisasterCard({super.key});

  @override
  State<ActiveDisasterCard> createState() => _ActiveDisasterCardState();
}

class _ActiveDisasterCardState extends State<ActiveDisasterCard> {
  bool _isLoading = false;
  String _message = "Tap the button to scan for potential disasters in your area.";
  FloodPrediction? _floodPrediction;
  CyclonePrediction? _cyclonePrediction;
  EarthquakePrediction? _earthquakePrediction;
  bool _hasError = false;
  DateTime? _lastScanTime;

  final DisasterApiService _apiService = DisasterApiService();

  Future<void> _scanForDisasters() async {
    setState(() {
      _isLoading = true;
      _message = "Scanning for disasters...";
      _floodPrediction = null;
      _cyclonePrediction = null;
      _earthquakePrediction = null;
      _hasError = false;
    });

    // 1. Get Location
    // Ensure location has been fetched. If not, maybe prompt user or use a default.
    // For now, assuming LocationService.requestLocationAndFCM() has been called elsewhere (e.g., at app start)
    // and LocationService.currentPosition is available.
    var position = LocationService.currentPosition; // Use 'var' to allow reassignment

    if (position == null) {
      // Try to fetch location if not available
      await LocationService.requestLocationAndFCM();
      position = LocationService.currentPosition; // Check again
      if (position == null) {
         setState(() {
          _isLoading = false;
          _message = "Could not retrieve your location. Please ensure location services are enabled and permissions are granted.";
          _hasError = true;
        });
        return;
      }
    }

    final lat = position.latitude; // Use the potentially updated position
    final lon = position.longitude; // Use the potentially updated position

    // 2. Call APIs
    try {
      final floodFuture = _apiService.getFloodPrediction(lat, lon);
      final cycloneFuture = _apiService.getCyclonePrediction(lat, lon);
      final earthquakeFuture = _apiService.getEarthquakePrediction(); // No lat/lon for this one

      // Wait for all API calls to complete
      final results = await Future.wait([
        floodFuture,
        cycloneFuture,
        earthquakeFuture,
      ]);

      _floodPrediction = results[0] as FloodPrediction?;
      _cyclonePrediction = results[1] as CyclonePrediction?;
      _earthquakePrediction = results[2] as EarthquakePrediction?;

      // Refined message handling
      if (!_hasError) {
        _lastScanTime = DateTime.now(); // Set scan time here
        if (_hasSignificantAlert()) {
          _message = "Potential disaster alerts for your location. Please review below.";
        } else if (_floodPrediction == null && _cyclonePrediction == null && _earthquakePrediction == null) {
          _message = "No specific disaster alerts found for your current location from our models.";
        } else {
          // Cases where there might be data, but not meeting "significant alert" criteria (e.g. low flood risk only)
          _message = "Scan complete. See details below.";
        }
      }
    } catch (e) {
      print("Error scanning disasters: $e");
      _message = "An error occurred while scanning for disasters. Please try again.";
      _hasError = true;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color _getFloodRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Colors.red.shade700;
      case 'medium': // Assuming 'Medium' is a possible value
        return Colors.orange.shade700;
      case 'low':
        return Colors.green.shade700;
      default:
        return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    }
  }

  Widget _buildFloodResult(FloodPrediction prediction) {
    final String risk = prediction.floodRisk;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Flood Alert", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text("District: ${prediction.matchedDistrict}"),
          Text(
            "Risk Level: $risk",
            style: TextStyle(color: _getFloodRiskColor(risk), fontWeight: FontWeight.bold),
          ),
          const Divider(height: 16, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildCycloneResult(CyclonePrediction prediction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Cyclone Update", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text("Condition: ${prediction.cycloneCondition}"),
          Text("Affected District: ${prediction.location.district}"),
          Text("Wind Speed: ${prediction.weatherData.usaWind} m/s"),
          Text("Last Updated: ${prediction.timestampUtc}"),
          const Divider(height: 16, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildEarthquakeResult(EarthquakePrediction prediction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Earthquake Watch", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (prediction.highRiskCities.isEmpty)
            const Text("No immediate high-risk areas identified by the model.")
          else ...[
            const Text("Potential High-Risk Cities:"),
            ...prediction.highRiskCities.map((city) => Text("- ${city.city}, ${city.state} (Magnitude: ${city.magnitude})")).toList(),
            const SizedBox(height: 8),
            if (prediction.readMoreUrl.isNotEmpty)
              InkWell(
                child: Text(
                  "Read More on RISEQ",
                  style: TextStyle(decoration: TextDecoration.underline, color: Theme.of(context).colorScheme.primary),
                ),
                onTap: () async {
                  final Uri url = Uri.parse(prediction.readMoreUrl);
                  if (!await launchUrl(url)) {
                    // Consider showing a snackbar or message if launch fails
                    print('Could not launch ${prediction.readMoreUrl}');
                  }
                },
              ),
          ],
          const Divider(height: 16, thickness: 1),
        ],
      ),
    );
  }

  bool _hasSignificantAlert() {
    if (_floodPrediction != null && (_floodPrediction!.floodRisk.toLowerCase() == 'high' || _floodPrediction!.floodRisk.toLowerCase() == 'medium')) {
      return true;
    }
    if (_cyclonePrediction != null && _cyclonePrediction!.cycloneCondition.toLowerCase() != 'no cyclone' && _cyclonePrediction!.cycloneCondition.toLowerCase() != 'depression' && _cyclonePrediction!.cycloneCondition.isNotEmpty) {
      // Consider conditions like 'cyclonic storm', 'severe cyclonic storm' as significant
      return true;
    }
    if (_earthquakePrediction != null && _earthquakePrediction!.highRiskCities.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Active Disaster Scan",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_lastScanTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text(
                  "Last scanned: ${DateFormat('MMM d, yyyy hh:mm a').format(_lastScanTime!)}",
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8.0), // Adjusted spacing a bit
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // Display general message or error message based on state
              if (_message.isNotEmpty && // Show message if it's not empty
                  (_hasError || // always show if error
                   _isLoading || // always show if loading
                   (_floodPrediction == null && _cyclonePrediction == null && _earthquakePrediction == null) || // show if no results yet
                   _message == "Tap the button to scan for potential disasters in your area." // show initial prompt
                  ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: _hasError ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
                  ),
                ),

              // Detailed results section
              if (!_isLoading && !_hasError) ...[
                if (_floodPrediction == null &&
                    _cyclonePrediction == null &&
                    _earthquakePrediction == null &&
                    _message != "Tap the button to scan for potential disasters in your area." &&
                    _message != "Scanning for disasters..." && // ensure it's not the loading message
                    _message != "Could not retrieve your location. Please ensure location services are enabled and permissions are granted." && // ensure not location error
                    !_message.startsWith("An error occurred") // ensure not a general API error
                    )
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "No active disaster alerts for your location from our models.", // Default "no results" message
                      textAlign: TextAlign.center,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                if (_floodPrediction != null) _buildFloodResult(_floodPrediction!),
                if (_cyclonePrediction != null) _buildCycloneResult(_cyclonePrediction!),
                if (_earthquakePrediction != null) _buildEarthquakeResult(_earthquakePrediction!),
              ],

              if (!_isLoading && !_hasError && _hasSignificantAlert()) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: Icon(Icons.health_and_safety_outlined, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    "View Safety Guidelines",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Safety guidelines feature coming soon!")),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8.0), // Adjusted spacing
              ElevatedButton.icon(
                icon: const Icon(Icons.radar),
                label: const Text("Scan for Disasters"),
                onPressed: _scanForDisasters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            // This specific error message display at the bottom might be redundant if the main message area handles it.
            // Let's remove this redundant part based on the logic above.
            // if (_hasError && !_isLoading)
            //    Padding(
            //      padding: const EdgeInsets.only(top: 8.0),
            //      child: Text(
            //        _message, // This would be the error message
            //        style: TextStyle(color: Theme.of(context).colorScheme.error),
            //        textAlign: TextAlign.center,
            //      ),
            //    )
          ],
        ),
      ),
    );
  }
}
