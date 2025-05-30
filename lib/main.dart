import 'package:d_m/app/modules/splash_screen.dart';
import 'package:flutter/material.dart';
import 'app/modules/civilian_dashboard/views/civilian_dashboard_view.dart';
import 'app/modules/learn/views/learn_page.dart';
import 'app/modules/refugee_camp/views/refugee_camp_page.dart';
import 'app/modules/sos/views/sos_page.dart';
import 'app/modules/user_guide/views/user_guide_page.dart';
import 'app/modules/call/views/call_page.dart';
import 'app/modules/profile/views/profile_page.dart';
import 'app/modules/community_history/views/community_page.dart';
import 'app/modules/ai_chatbot.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // Import Gemini
import 'package:firebase_core/firebase_core.dart';
import 'app/modules/donate.dart';
// Add this to the top of lib/main.dart
import 'package:d_m/providers/language_provider.dart';
import 'package:provider/provider.dart';

import 'services/location_service.dart';

void main() async {
  print("Initializing app...");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await LocationService.requestLocationAndFCM();

  print("Firebase initialized");
  Gemini.init(apiKey: 'AIzaSyADGh1jYjjOA5hNJVVFUzBwNZ-SVMYdqXc');
  print("Gemini initialized");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        // Any other providers you need
      ],
      child: MyApp(),
    ),
  );
  print("App started");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final Color primaryColor = Color(0xFF5F6898);
  static const Color lightBackground = Color(0xFFE3F2FD);
  static const Color secondaryBackground = Color(0xFFBBDEFB);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: lightBackground,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: secondaryBackground,
          background: lightBackground,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/community_history') {
          return MaterialPageRoute(builder: (context) => const CommunityPage());
        }
        final pageBuilder = routes[settings.name];
        if (pageBuilder != null) {
          return MaterialPageRoute(builder: (context) => pageBuilder(context));
        }
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: const Center(child: Text("Page not found")),
          ),
        );
      },
    );
  }

  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/civilian_dashboard': (context) => const CivilianDashboardView(),
    '/learn': (context) => const LearnPage(),
    '/CommunityPage': (context) => const CommunityPage(),
    '/refugee_camp': (context) => RefugeeCampMap(),
    '/sos': (context) => const SOSPage(),
    '/user_guide': (context) => const UserGuidePage(),
    '/call': (context) => CallPage(),
    '/profile': (context) => ProfilePage(),
    '/ai_chatbot': (context) => AIChatbotScreen(),
    '/donate': (context) => DonatePage(),
  };
}
