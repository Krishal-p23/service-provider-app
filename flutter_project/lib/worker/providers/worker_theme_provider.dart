import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true; // DEFAULT TO DARK MODE
  String _themeMode = 'Dark'; // 'Light', 'Dark', or 'System' - DEFAULT TO DARK

  bool get isDarkMode => _isDarkMode;
  String get themeMode => _themeMode;
  
  // Add getter for MaterialApp's themeMode
  ThemeMode get materialThemeMode {
    if (_themeMode == 'Dark') return ThemeMode.dark;
    if (_themeMode == 'Light') return ThemeMode.light;
    return ThemeMode.system;
  }

  WorkerThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('worker_dark_mode') ?? true; // DEFAULT TO DARK
      _themeMode = prefs.getString('worker_theme_mode') ?? 'Dark'; // DEFAULT TO DARK
      notifyListeners();
    } catch (e) {
      // If shared_preferences fails, use default values (Dark mode)
      _isDarkMode = true;
      _themeMode = 'Dark';
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    _themeMode = value ? 'Dark' : 'Light';
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('worker_dark_mode', value);
      await prefs.setString('worker_theme_mode', _themeMode);
    } catch (e) {
      // Ignore errors
    }
    
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    // Update isDarkMode based on theme mode for the toggle switch
    if (mode == 'System') {
      // When System is selected, isDarkMode will reflect system preference
      // This is handled by the MaterialApp's themeMode
      _isDarkMode = true; // Keep as true for visual consistency
    } else {
      _isDarkMode = mode == 'Dark';
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('worker_theme_mode', mode);
      await prefs.setBool('worker_dark_mode', _isDarkMode);
    } catch (e) {
      // Ignore errors
    }
    
    notifyListeners();
  }
}
