import 'dart:convert';
import 'package:d_m/app/common/widgets/translatable_text.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  bool _isSending = false;
  static const String serverKey =
      "YOUR_FCM_SERVER_KEY"; // 🔹 Replace with actual FCM Server Key

  // 🔹 Function to get user's current location
  Future<String> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return "${position.latitude}, ${position.longitude}";
    } catch (e) {
      return "Location not available";
    }
  }

  // 🔹 Fetch all FCM tokens of gsc app users
  Future<List<String>> _getFCMTokens() async {
    List<String> tokens = [];
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('FCM_TOKENS').get();
      for (var doc in snapshot.docs) {
        tokens.add(doc['token']); // 🔹 Assuming 'token' is the field name
      }
    } catch (e) {
      print("Error fetching FCM tokens: $e");
    }
    return tokens;
  }

  // 🔹 Function to send FCM notification to gsc app
  Future<void> _sendSOSNotification(String location) async {
    List<String> tokens = await _getFCMTokens();
    if (tokens.isEmpty) {
      print("No FCM tokens found!");
      return;
    }

    for (String token in tokens) {
      try {
        var url = Uri.parse("https://fcm.googleapis.com/fcm/send");

        var body = jsonEncode({
          "to": token,
          "notification": {
            "title": "🚨 SOS Alert",
            "body": "A user has activated an SOS alert at $location!",
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
          },
          "data": {"screen": "SOS_ALERTS", "location": location},
        });

        var response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "key=$serverKey",
          },
          body: body,
        );

        print("FCM Response: ${response.body}");
      } catch (e) {
        print("Error sending notification: $e");
      }
    }
  }

  // 🔴 Function to send SOS alert to Firestore and notify gsc
  Future<void> _sendSOS() async {
    setState(() {
      _isSending = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? "Unknown User";
    String userName = user?.displayName ?? "Anonymous";
    String userPhone = user?.phoneNumber ?? "No Phone";
    String location = await _getUserLocation();
    String timestamp = DateTime.now().toString();

    await FirebaseFirestore.instance.collection('SOS_ALERTS').add({
      'userId': userId,
      'name': userName,
      'phone': userPhone,
      'location': location,
      'timestamp': timestamp,
      'status': 'pending',
    });

    await _sendSOSNotification(location); // 🔹 Send FCM notification

    setState(() {
      _isSending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: TranslatableText('🚨 SOS Alert Sent! Help is on the way.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const TranslatableText("SOS Emergency"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TranslatableText(
              "🔴 Emergency SOS",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSending ? null : _sendSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child:
              _isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const TranslatableText(
                "SEND SOS",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const TranslatableText(
              "📡 Your SOS alert will be sent to the nearest rescue team.",
              style: TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
