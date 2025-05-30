import 'package:flutter/material.dart';
import 'package:d_m/services/translation_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _languageCode = 'en';

  String get languageCode => _languageCode;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    _languageCode = await TranslationService.getCurrentLanguage();
    notifyListeners();
  }

  Future<void> changeLanguage(String newCode) async {
    await TranslationService.setLanguage(newCode);
    _languageCode = newCode;
    notifyListeners();
  }

  Future<String> translateText(String text) async {
    return await TranslationService.translateText(text, _languageCode);
  }
}
