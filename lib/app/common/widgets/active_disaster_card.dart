import 'package:flutter/material.dart';
import 'package:d_m/services/location_service.dart';
import 'package:d_m/services/disaster_service.dart';
import 'package:d_m/app/data/models/flood_prediction_response.dart';
import 'package:d_m/app/data/models/cyclone_prediction_response.dart';
import 'package:d_m/app/data/models/earthquake_prediction_response.dart';
import 'package:d_m/app/modules/disaster_details/views/disaster_details_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveDisasterCard extends StatefulWidget {
  const ActiveDisasterCard({super.key});

  @override
  State<ActiveDisasterCard> createState() => _ActiveDisasterCardState();
}

class _ActiveDisasterCardState extends State<ActiveDisasterCard> {
  final DisasterService _disasterService = DisasterService();
  bool _isLoading = true;
  String? _errorMessage;
  double? _currentLatitude;
  double? _currentLongitude;
  FloodPredictionResponse? _floodPrediction;
  CyclonePredictionResponse? _cyclonePrediction;
  EarthquakePredictionResponse? _earthquakePrediction;
  DateTime? _lastUpdated;

  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _fetchDisasterData();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _fetchDisasterData() async {
    if (!_isMounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      // Optionally clear previous data
      _floodPrediction = null;
      _cyclonePrediction = null;
      _earthquakePrediction = null;
    });

    try {
      // Ensure location permissions and fetch if needed
      await LocationService.requestLocationAndFCM();
      _currentLatitude = LocationService.currentLatitude;
      _currentLongitude = LocationService.currentLongitude;

      if (_currentLatitude == null || _currentLongitude == null) {
        if (_isMounted) {
          setState(() {
            _errorMessage = 'Could not retrieve location. Please ensure location services are enabled and permissions are granted.';
            _isLoading = false;
          });
        }
        return;
      }

      // All API calls will be attempted, even if some fail.
      // Errors will be collected and can be displayed individually or as a general message.
      String? floodError, cycloneError, earthquakeError;

      try {
        final floodResponse = await _disasterService.getFloodPrediction(_currentLatitude!, _currentLongitude!);
        if (_isMounted) setState(() => _floodPrediction = floodResponse);
      } catch (e) {
        print('Error fetching flood prediction: $e');
        floodError = 'Flood data unavailable.';
      }

      try {
        final cycloneResponse = await _disasterService.getCyclonePrediction(_currentLatitude!, _currentLongitude!);
        if (_isMounted) setState(() => _cyclonePrediction = cycloneResponse);
      } catch (e) {
        print('Error fetching cyclone prediction: $e');
        cycloneError = 'Cyclone data unavailable.';
      }

      try {
        final earthquakeResponse = await _disasterService.getEarthquakePrediction();
        if (_isMounted) setState(() => _earthquakePrediction = earthquakeResponse);
      } catch (e) {
        print('Error fetching earthquake prediction: $e');
        earthquakeError = 'Earthquake data unavailable.';
      }

      // Consolidate error messages if any
      final errors = [floodError, cycloneError, earthquakeError].where((e) => e != null).toList();
      if (errors.isNotEmpty && _isMounted) {
        setState(() {
          // If all fail, show a general error. Otherwise, partial data might still be useful.
          if (errors.length == 3) {
            _errorMessage = 'Could not fetch disaster data. Please try again.';
          } else {
            _errorMessage = errors.join('\n'); // Or display them more granularly
          }
        });
      }

      // Update timestamp if any data was successfully fetched
      if (_isMounted) {
        setState(() {
          if (_floodPrediction != null || _cyclonePrediction != null || _earthquakePrediction != null) {
            _lastUpdated = DateTime.now();
          }
        });
      }

    } catch (e) {
      print('Error in _fetchDisasterData: $e');
      if (_isMounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (_isMounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DisasterDetailsPage(),
            settings: RouteSettings(
              arguments: {
                'floodPrediction': _floodPrediction,
                'cyclonePrediction': _cyclonePrediction,
                'earthquakePrediction': _earthquakePrediction,
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Disaster Scan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _isLoading ? null : _fetchDisasterData,
                    tooltip: 'Refresh Data',
                  ),
                ],
              ),
              if (_lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                  child: Text(
                    'Last updated: ${_formatDateTime(_lastUpdated!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 16.0),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage != null && _floodPrediction == null && _cyclonePrediction == null && _earthquakePrediction == null)
              // Only show top-level error if all data is missing
                Center(
                  child: Column(
                    children: [
                      Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _fetchDisasterData, child: const Text('Retry'))
                    ],
                  ),
                )
              else
                _buildDisasterInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisasterInfo() {
    return Center(
      child: Text(
        "Tap to view active disaster details.",
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    // Using intl package would be better for localization, but for simplicity:
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')} on ${dt.day}/${dt.month}/${dt.year}';
  }
}