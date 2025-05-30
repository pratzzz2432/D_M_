import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  // Replace with your actual Google Cloud API key
  static const String apiKey = 'AIzaSyDx5jUKoJPNoeKSjbLcaCqMGrpVHErGhq0';
  static const String baseUrl = 'https://translation.googleapis.com/language/translate/v2';

  // Cache for translated texts to minimize API calls
  static Map<String, Map<String, String>> _translationCache = {};

  // Preloaded disaster-related translations to avoid API calls for common terms
  static final Map<String, Map<String, String>> _disasterTranslations = {
    'hi': {
      'Earthquake': 'भूकंप',
      'Flood': 'बाढ़',
      'Cyclone': 'चक्रवात',
      'No active disasters': 'कोई सक्रिय आपदा नहीं',
      'Loading...': 'लोड हो रहा है...',
      'Failed to load data': 'डेटा लोड करने में विफल',
    },
    'ta': {
      'Earthquake': 'நிலநடுக்கம்',
      'Flood': 'வெள்ளம்',
      'Cyclone': 'புயல்',
      'No active disasters': 'செயலில் பேரழிவுகள் இல்லை',
      'Loading...': 'ஏற்றுகிறது...',
      'Failed to load data': 'தரவை ஏற்ற முடியவில்லை',
    },
    'te': {
      'Earthquake': 'భూకంపం',
      'Flood': 'వరద',
      'Cyclone': 'తుఫాను',
      'No active disasters': 'చురుకైన విపత్తులు లేవు',
      'Loading...': 'లోడ్ అవుతోంది...',
      'Failed to load data': 'డేటాను లోడ్ చేయడం విఫలమైంది',
    },
    'kn': {
      'Earthquake': 'ಭೂಕಂಪ',
      'Flood': 'ಪ್ರವಾಹ',
      'Cyclone': 'ಚಂಡಮಾರುತ',
      'No active disasters': 'ಸಕ್ರಿಯ ವಿಪತ್ತುಗಳಿಲ್ಲ',
      'Loading...': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
      'Failed to load data': 'ಡೇಟಾ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ',
    },
    'ml': {
      'Earthquake': 'ഭൂകമ്പം',
      'Flood': 'പ്രളയം',
      'Cyclone': 'ചുഴലിക്കാറ്റ്',
      'No active disasters': 'സജീവ ദുരന്തങ്ങളൊന്നുമില്ല',
      'Loading...': 'ലോഡുചെയ്യുന്നു...',
      'Failed to load data': 'ഡാറ്റ ലോഡുചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു',
    },
    'bn': {
      'Earthquake': 'ভূমিকম্প',
      'Flood': 'বন্যা',
      'Cyclone': 'ঘূর্ণিঝড়',
      'No active disasters': 'কোন সক্রিয় দুর্যোগ নেই',
      'Loading...': 'লোড হচ্ছে...',
      'Failed to load data': 'ডেটা লোড করতে ব্যর্থ হয়েছে',
    },
    'mr': {
      'Earthquake': 'भूकंप',
      'Flood': 'पूर',
      'Cyclone': 'चक्रीवादळ',
      'No active disasters': 'कोणतीही सक्रिय आपत्ती नाही',
      'Loading...': 'लोड करत आहे...',
      'Failed to load data': 'डेटा लोड करण्यात अयशस्वी',
    },
    'gu': {
      'Earthquake': 'ધરતીકંપ',
      'Flood': 'પૂર',
      'Cyclone': 'વાવાઝોડું',
      'No active disasters': 'કોઈ સક્રિય આપત્તિઓ નથી',
      'Loading...': 'લોડ થઈ રહ્યું છે...',
      'Failed to load data': 'ડેટા લોડ કરવામાં નિષ્ફળ',
    },
    'pa': {
      'Earthquake': 'ਭੂਚਾਲ',
      'Flood': 'ਹੜ੍ਹ',
      'Cyclone': 'ਚੱਕਰਵਾਤ',
      'No active disasters': 'ਕੋਈ ਸਰਗਰਮ ਆਫ਼ਤਾਂ ਨਹੀਂ',
      'Loading...': 'ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ...',
      'Failed to load data': 'ਡਾਟਾ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਫਲ',
    },
    'or': {
      'Earthquake': 'ଭୂମିକମ୍ପ',
      'Flood': 'ବନ୍ୟା',
      'Cyclone': 'ଘୂର୍ଣ୍ଣିବାତ୍ୟା',
      'No active disasters': 'କୌଣସି ସକ୍ରିୟ ବିପର୍ଯ୍ୟୟ ନାହିଁ',
      'Loading...': 'ଲୋଡ୍ ହେଉଛି...',
      'Failed to load data': 'ତଥ୍ୟ ଲୋଡ୍ କରିବାରେ ବିଫଳ',
    },
    'as': {
      'Earthquake': 'ভূমিকম্প',
      'Flood': 'বান',
      'Cyclone': 'ঘূৰ্ণীবতাহ',
      'No active disasters': 'কোনো সক্ৰিয় দুৰ্যোগ নাই',
      'Loading...': 'লোড হৈ আছে...',
      'Failed to load data': 'ডাটা লোড কৰিবলৈ বিফল',
    },
  };

  // Available languages
  static final List<LanguageOption> availableLanguages = [
    LanguageOption(code: 'en', name: 'English', englishName: 'English'),
    LanguageOption(code: 'hi', name: 'Hindi', englishName: 'Hindi'),
    LanguageOption(code: 'ta', name: 'Tamil', englishName: 'Tamil'),
    LanguageOption(code: 'te', name: 'Telugu', englishName: 'Telugu'),
    LanguageOption(code: 'kn', name: 'Kannada', englishName: 'Kannada'),
    LanguageOption(code: 'ml', name: 'Malayalam', englishName: 'Malayalam'),
    // Other Major Indian Languages
    LanguageOption(code: 'bn', name: 'Bengali', englishName: 'Bengali'),
    LanguageOption(code: 'mr', name: 'Marathi', englishName: 'Marathi'),
    LanguageOption(code: 'gu', name: 'Gujarati', englishName: 'Gujarati'),
    LanguageOption(code: 'pa', name: 'Punjabi', englishName: 'Punjabi'),
    LanguageOption(code: 'or', name: 'Odia', englishName: 'Odia'),
    LanguageOption(code: 'as', name: 'Assamese', englishName: 'Assamese'),
    // Add more languages as needed
  ];

  // Get current language from SharedPreferences
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('Language') ?? 'en';
  }

  // Save language preference
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Language', languageCode);
  }

  // Check if we have a preloaded translation for disaster terms
  static String? getPreloadedTranslation(String text, String targetLanguage) {
    if (targetLanguage == 'en') return text;

    if (_disasterTranslations.containsKey(targetLanguage) &&
        _disasterTranslations[targetLanguage]!.containsKey(text)) {
      return _disasterTranslations[targetLanguage]![text];
    }
    return null;
  }

  static Future<String> translateText(String text,
      String targetLanguage) async {
    if (targetLanguage == 'en') return text;

    // Check preloaded disaster terms first
    final preloaded = getPreloadedTranslation(text, targetLanguage);
    if (preloaded != null) return preloaded;

    // Check cache
    if (_translationCache.containsKey(text) &&
        _translationCache[text]!.containsKey(targetLanguage)) {
      return _translationCache[text]![targetLanguage]!;
    }

    try {
      final url = Uri.parse('$baseUrl?key=$apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final translatedText = json['data']['translations'][0]['translatedText'];

        // Save to cache
        _translationCache[text] ??= {};
        _translationCache[text]![targetLanguage] = translatedText;

        return translatedText;
      } else {
        return text; // fallback
      }
    } catch (e) {
      print('Translation error: $e');
      return text; // Return original text if translation fails
    }
  }
}


// Language option model
class LanguageOption {
  final String code;
  final String name; // Native name
  final String englishName; // English name for reference

  LanguageOption({
    required this.code,
    required this.name,
    required this.englishName
  });
}
