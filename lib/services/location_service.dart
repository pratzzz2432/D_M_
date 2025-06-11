import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static String? _currentCity;
  static Position? _currentPosition;

  static Future<void> requestLocationAndFCM() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    // Request permission for location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permission permanently denied.");
      return;
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _currentPosition = position;

    // Convert coordinates to city name
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    String city = placemarks[0].locality ?? "Unknown";
    _currentCity = city;

    // Get FCM Token
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    if (token != null) {
      Map<String, dynamic> userData = {
        'token': token,
        'city': city,
      };
      if (_currentPosition != null) {
        userData['latitude'] = _currentPosition!.latitude;
        userData['longitude'] = _currentPosition!.longitude;
      }
      // Store user location and FCM token in Firestore
      await FirebaseFirestore.instance.collection('users').doc(token).set(userData);
      print("Stored location, FCM token, and coordinates in Firestore.");
    }
  }

  static String? get currentCity => _currentCity;
  static Position? get currentPosition => _currentPosition;
}
