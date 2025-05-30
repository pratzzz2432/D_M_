import 'dart:convert';
import 'package:http/http.dart' as http;

class LanguageService {
  static const String apiKey = "AIzaSyDx5jUKoJPNoeKSjbLcaCqMGrpVHErGhq0"; // Replace with your API key

  static Future<String> translateText(String text, String targetLang) async {
    final url =
        "https://translation.googleapis.com/language/translate/v2?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "q": text,
        "target": targetLang,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"]["translations"][0]["translatedText"];
    } else {
      return "Translation Error";
    }
  }
}

