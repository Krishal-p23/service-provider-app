import 'package:flutter/foundation.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'English';
  bool _isLanguageApplied = false;

  String get currentLanguage => _currentLanguage;
  bool get isLanguageApplied => _isLanguageApplied;

  // Available languages
  final List<Map<String, dynamic>> availableLanguages = [
    {
      'name': 'English',
      'code': 'en',
      'enabled': true,
    },
    {
      'name': 'Hindi',
      'code': 'hi',
      'enabled': false, // Not yet implemented
    },
  ];

  // Set current language
  void setLanguage(String languageName) {
    // Check if language is enabled
    final language = availableLanguages.firstWhere(
      (lang) => lang['name'] == languageName,
      orElse: () => availableLanguages[0],
    );

    if (language['enabled'] == true) {
      _currentLanguage = languageName;
      _isLanguageApplied = false;
      notifyListeners();
    }
  }

  // Apply language changes
  void applyLanguage() {
    _isLanguageApplied = true;
    notifyListeners();
    
    // In a real app, this would trigger app-wide language change
    // For now, it's just a flag
  }

  // Get language code
  String getLanguageCode() {
    final language = availableLanguages.firstWhere(
      (lang) => lang['name'] == _currentLanguage,
      orElse: () => availableLanguages[0],
    );
    return language['code'];
  }

  // Check if language is enabled
  bool isLanguageEnabled(String languageName) {
    final language = availableLanguages.firstWhere(
      (lang) => lang['name'] == languageName,
      orElse: () => {'enabled': false},
    );
    return language['enabled'] == true;
  }

  // Reset to default language
  void resetToDefault() {
    _currentLanguage = 'English';
    _isLanguageApplied = true;
    notifyListeners();
  }
}