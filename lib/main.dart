import 'package:d_m/app/modules/splash_screen.dart';
import 'package:d_m/app/modules/login_page.dart';
import 'package:d_m/app/modules/civilian_dashboard/views/civilian_dashboard_view.dart';
import 'package:d_m/app/modules/predictive_ai/views/predictive_ai_page.dart';
import 'package:d_m/app/modules/learn/views/learn_page.dart';
import 'package:d_m/app/modules/refugee_camp/views/refugee_camp_page.dart';
import 'package:d_m/app/modules/sos/views/sos_page.dart';
import 'package:d_m/app/modules/user_guide/views/user_guide_page.dart';
import 'package:d_m/app/modules/call/views/call_page.dart';
import 'package:d_m/app/modules/profile/views/profile_page.dart';
import 'package:d_m/app/modules/community_history/views/community_history_page.dart';
import 'package:d_m/app/modules/ai_chatbot.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Gemini.init(apiKey: 'AIzaSyADGh1jYjjOA5hNJVVFUzBwNZ-SVMYdqXc');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Management App',
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // ✅ Automatically check login state
    );
  }
}

// ✅ Wrapper to check authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // ✅ Show splash screen while checking
        }
        if (snapshot.data == true && FirebaseAuth.instance.currentUser != null) {
          return const CivilianDashboardView(); // ✅ Stay logged in after restart
        }
        return const LoginPage(); // ❌ Redirect to login if no session
      },
    );
  }
}
