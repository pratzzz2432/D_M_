import 'package:d_m/app/common/widgets/translatable_text.dart';
import 'package:flutter/material.dart';

import 'package:d_m/app/common/widgets/common_scaffold.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'dart:math'; // For calculating dummy ETA
import 'package:url_launcher/url_launcher.dart'; // For launching Google Maps




class RefugeeCampMap extends StatefulWidget {
  @override
  _RefugeeCampMapState createState() => _RefugeeCampMapState();
}

class _RefugeeCampMapState extends State<RefugeeCampMap> {
  GoogleMapController? _mapController;
  Location _location = Location();
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndFetch();
  }

  /// ✅ Step 1: Check location permissions and fetch location & camp data
  void _checkPermissionsAndFetch() async {
    perm.PermissionStatus status = await perm.Permission.location.request();
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _fetchUserLocation();
      _fetchCamps();
    } else {
      print("❌ Location permission denied.");
    }
  }

  /// ✅ Step 2: Fetch user's current location
  void _fetchUserLocation() async {
    var locationData = await _location.getLocation();
    setState(() {
      _currentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      _markers.add(
        Marker(
          markerId: MarkerId('userLocation'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
      _moveCameraToUser();
    });
  }

  /// ✅ Step 3: Fetch refugee camps from Firestore
  void _fetchCamps() {
    FirebaseFirestore.instance
        .collection('refugee_camps')
        .snapshots()
        .listen(
          (snapshot) {
        if (snapshot.docs.isEmpty) {
          print("⚠️ No refugee camps found.");
        } else {
          Set<Marker> tempMarkers = {};
          tempMarkers.add(
            Marker(
              markerId: MarkerId('userLocation'),
              position: _currentPosition ?? LatLng(20.5937, 78.9629),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
              infoWindow: InfoWindow(title: 'Your Location'),
            ),
          );

          for (var camp in snapshot.docs) {
            var data = camp.data();
            if (data.containsKey('location') &&
                data['location'] is GeoPoint) {
              GeoPoint geoPoint = data['location'];
              LatLng campPosition = LatLng(
                geoPoint.latitude,
                geoPoint.longitude,
              );

              // Calculate dummy ETA
              String eta = _getDummyETA(_currentPosition, campPosition);

              // Add camp marker with tap listener
              tempMarkers.add(
                Marker(
                  markerId: MarkerId(data['name']),
                  position: campPosition,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: InfoWindow(
                    title: data['name'],
                    snippet: "Capacity: ${data['capacity']}",
                    onTap: () {
                      _launchGoogleMapsNavigation(campPosition);
                    },
                  ),
                  onTap: () {
                    if (_currentPosition != null) {
                      // Draw route when camp marker is tapped
                      _drawRoute(_currentPosition!, campPosition);

                      // Show the camp details dialog
                      _showCampDetails(data, campPosition);

                      // Update InfoWindow
                      _mapController?.showMarkerInfoWindow(
                        MarkerId(data['name']),
                      );
                    }
                  },
                ),
              );
            }
          }

          setState(() {
            _markers = tempMarkers;
          });

          print("✅ Real-time camps updated: ${tempMarkers.length}");
        }
      },
      onError: (e) {
        print("❌ Firestore Error: $e");
      },
    );
  }

  /// ✅ Step 4: Move camera to user location after fetching
  void _moveCameraToUser() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 12.0),
      );
    }
  }

  /// ✅ Step 5: Show route to selected refugee camp (Camera adjustment)
  void _showRouteToCamp(LatLng campPosition) {
    if (_currentPosition == null) return;

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('routeStart'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: 'Starting Point'),
        ),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('routeEnd'),
          position: campPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Refugee Camp'),
        ),
      );
    });

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _currentPosition!.latitude < campPosition.latitude
                ? _currentPosition!.latitude
                : campPosition.latitude,
            _currentPosition!.longitude < campPosition.longitude
                ? _currentPosition!.longitude
                : campPosition.longitude,
          ),
          northeast: LatLng(
            _currentPosition!.latitude > campPosition.latitude
                ? _currentPosition!.latitude
                : campPosition.latitude,
            _currentPosition!.longitude > campPosition.longitude
                ? _currentPosition!.longitude
                : campPosition.longitude,
          ),
        ),
        50,
      ),
    );
  }

  /// ✅ NEW: Launch Google Maps navigation
  void _launchGoogleMapsNavigation(LatLng destination) async {
    if (_currentPosition == null) return;

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${destination.latitude},${destination.longitude}&travelmode=driving';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch Google Maps');
    }
  }

  /// ✅ Draw route using Polylines - PROTOTYPE VERSION
  void _drawRoute(LatLng origin, LatLng destination) {
    // Create a sensible dummy route (straight line with few waypoints)
    List<LatLng> points = _createDummyRoutePoints(origin, destination);

    // Create a polyline with the generated points
    final polyline = Polyline(
      polylineId: PolylineId('route'),
      color: const Color.fromARGB(91, 42, 44, 45),
      width: 3,
      points: points,
    );

    setState(() {
      _polylines = {polyline};
    });

    // Adjust camera to show the route
    _showRouteToCamp(destination);
  }

  /// ✅ Create dummy route points for prototype
  List<LatLng> _createDummyRoutePoints(LatLng origin, LatLng destination) {
    List<LatLng> points = [];

    // Add starting point
    points.add(origin);

    // Add some intermediate waypoints for a realistic-looking route
    // Calculate a midpoint and add some randomness
    double latMid = (origin.latitude + destination.latitude) / 2;
    double lngMid = (origin.longitude + destination.longitude) / 2;

    // Add slight "bends" to the route to make it look realistic
    Random random = Random();
    double latOffset = (random.nextDouble() * 0.02) - 0.01; // ±0.01 degrees
    double lngOffset = (random.nextDouble() * 0.02) - 0.01; // ±0.01 degrees

    // Add first bend
    points.add(
      LatLng(
        (origin.latitude * 0.7) + (latMid * 0.3) + latOffset,
        (origin.longitude * 0.7) + (lngMid * 0.3) + lngOffset,
      ),
    );

    // Add a midpoint
    points.add(LatLng(latMid + latOffset / 2, lngMid + lngOffset / 2));

    // Add second bend
    points.add(
      LatLng(
        (destination.latitude * 0.7) + (latMid * 0.3) - latOffset,
        (destination.longitude * 0.7) + (lngMid * 0.3) - lngOffset,
      ),
    );

    // Add destination
    points.add(destination);

    return points;
  }

  /// ✅ Calculate a sensible dummy ETA
  String _getDummyETA(LatLng? origin, LatLng destination) {
    if (origin == null) return "Unknown";

    // Calculate distance between points (in km)
    double distance = _calculateDistance(origin, destination);

    // Assume average speed of 40 km/h
    double hours = distance / 40;

    // Format the duration
    if (hours < 1) {
      int minutes = (hours * 60).round();
      return "$minutes mins";
    } else if (hours < 24) {
      int hrs = hours.floor();
      int mins = ((hours - hrs) * 60).round();
      return "$hrs hr${hrs > 1 ? 's' : ''} $mins mins";
    } else {
      int days = (hours / 24).floor();
      int remainingHours = (hours % 24).floor();
      return "$days day${days > 1 ? 's' : ''} $remainingHours hr${remainingHours > 1 ? 's' : ''}";
    }
  }

  /// Helper method to calculate distance between two coordinates
  double _calculateDistance(LatLng point1, LatLng point2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a =
        0.5 -
            c((point2.latitude - point1.latitude) * p) / 2 +
            c(point1.latitude * p) *
                c(point2.latitude * p) *
                (1 - c((point2.longitude - point1.longitude) * p)) /
                2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// ✅ Show camp details dialog with route showing functionality
  void _showCampDetails(Map<String, dynamic> campData, LatLng campPosition) {
    String eta = _getDummyETA(_currentPosition, campPosition);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TranslatableText(campData['name'] ?? 'Camp Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow("Capacity", "${campData['capacity'] ?? '500'}"),
                _detailRow(
                  "Current Occupancy",
                  "${campData['current_occupancy'] ?? '342'}",
                ),
                _detailRow(
                  "Address",
                  campData['address'] ?? 'Camp ${campData['name']}, District 7',
                ),
                _detailRow("Contact", campData['contact'] ?? '+91 99XX XXXXX7'),
                _detailRow("ETA", eta),
                _detailRow(
                  "Resources",
                  campData['resources'] ?? 'Food, Water, Medical, Shelter',
                ),
                _detailRow(
                  "Coordinates",
                  "${campPosition.latitude.toStringAsFixed(6)}, ${campPosition.longitude.toStringAsFixed(6)}",
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: TranslatableText("Navigation"),
                  onPressed: () {
                    // Close the dialog
                    Navigator.pop(context);

                    // Launch Google Maps navigation
                    _launchGoogleMapsNavigation(campPosition);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: TranslatableText("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  /// Helper method to create detail rows
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatableText(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 91, 99, 106),
            ),
          ),
          TranslatableText(value),
          Divider(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TranslatableText("Refugee Camps")),
      body:
      _locationPermissionGranted
          ? GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(24.8108, 93.9386), // Default position (India)
          zoom: 4,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      )
          : Center(child: TranslatableText("Please grant location permissions.")),

    );
  }
}
