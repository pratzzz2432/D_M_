import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:d_m/app/common/widgets/language_selection_dialog.dart';
import 'package:d_m/app/common/widgets/translatable_text.dart';
import 'package:d_m/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:d_m/providers/language_provider.dart'; // ✅ Adjust the path if needed



class CommonScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Color primaryColor = const Color(0xFF5F6898);

  const CommonScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TranslatableText(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: body,
    );
  }
}

class CallPage extends StatelessWidget {
  final Color primaryColor = const Color(0xFF5F6898);
  final Color backgroundColor = const Color(0xFFE3F2FD);
  final Color boxColor = const Color(0xFFBBDEFB);

  final List<Map<String, dynamic>> emergencyContacts = [
    {'name': 'Police', 'icon': Icons.local_police, 'number': '100'},
    {'name': 'Fire Brigade', 'icon': Icons.local_fire_department, 'number': '101'},
    {'name': 'Ambulance', 'icon': Icons.local_hospital, 'number': '102'},
    {'name': 'Disaster Management', 'icon': Icons.warning, 'number': '1070'},
    {'name': 'State Disaster Management', 'icon': Icons.account_balance, 'number': '1077'},
    {'name': 'National Emergency', 'icon': Icons.call, 'number': '112'},
    {'name': 'Road Accident', 'icon': Icons.directions_car, 'number': '1033'},
    {'name': 'Women Helpline', 'icon': Icons.woman, 'number': '1091'},
    {'name': 'Child Helpline', 'icon': Icons.child_care, 'number': '1098'},
    {'name': 'Cyber Crime', 'icon': Icons.computer, 'number': '1930'},
    {'name': 'Poison Control', 'icon': Icons.science, 'number': '1800-11-6117'},
    {'name': 'COVID-19 Helpline', 'icon': Icons.health_and_safety, 'number': '1075'},
    {'name': 'Blood Bank', 'icon': Icons.bloodtype, 'number': '1910'},
    {'name': 'ABHA Health ID', 'icon': Icons.medical_services, 'number': '1800-11-4477'},
    {'name': 'NDRF Rescue', 'icon': Icons.directions_boat, 'number': '9711077372'},
    {'name': 'Earthquake & Tsunami', 'icon': Icons.terrain, 'number': '+91-11-24632998'},
    {'name': 'Cyclone Warning', 'icon': Icons.air, 'number': '+91-11-24623232'},
    {'name': 'Forest Fire', 'icon': Icons.forest, 'number': '1926'},
    {'name': 'Heatwave/Coldwave Advisory', 'icon': Icons.thermostat, 'number': '+91-11-24611115'},
    {'name': 'Indian Railways Emergency', 'icon': Icons.train, 'number': '139'},
    {'name': 'Airplane Crash Emergency', 'icon': Icons.flight, 'number': '+91-11-24632950'},
    {'name': 'Maritime & Oil Spill', 'icon': Icons.water, 'number': '1554'},
    {'name': 'Industrial Accidents', 'icon': Icons.factory, 'number': '1800-180-5523'},
    {'name': 'Anti-Terrorism', 'icon': Icons.shield, 'number': '1090'},
  ];

  CallPage({super.key});

  void _callNumber(String number) async {
    final Uri callUri = Uri.parse('tel:$number');
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      debugPrint('Could not launch $number');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Emergency Contacts',
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return Card(
            color: boxColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Icon(contact['icon'], size: 32, color: primaryColor),
              title: TranslatableText(
                contact['name'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: TranslatableText(
                contact['number'],
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () => _callNumber(contact['number']),
              ),
            ),
          );
        },
      ),
    );
  }
}
