import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveLanguagePreference(String languageCode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', languageCode);
}

Future<String> _loadLanguagePreference() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('selectedLanguage') ?? 'en'; // Default to English
}

