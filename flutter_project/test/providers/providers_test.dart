import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_project/customer/providers/language_provider.dart';
import 'package:flutter_project/theme/theme_provider.dart';

void main() {
  group('LanguageProvider', () {
    test('default state and language code', () {
      final provider = LanguageProvider();

      expect(provider.currentLanguage, 'English');
      expect(provider.getLanguageCode(), 'en');
      expect(provider.isLanguageApplied, false);
    });

    test('setLanguage only applies enabled languages', () {
      final provider = LanguageProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.setLanguage('Hindi');
      expect(provider.currentLanguage, 'English');

      provider.setLanguage('English');
      expect(provider.currentLanguage, 'English');
      expect(notifications, greaterThan(0));
    });

    test('applyLanguage, isLanguageEnabled and resetToDefault', () {
      final provider = LanguageProvider();

      provider.applyLanguage();
      expect(provider.isLanguageApplied, true);

      expect(provider.isLanguageEnabled('English'), true);
      expect(provider.isLanguageEnabled('Hindi'), false);
      expect(provider.isLanguageEnabled('Unknown'), false);

      provider.resetToDefault();
      expect(provider.currentLanguage, 'English');
      expect(provider.isLanguageApplied, true);
    });
  });

  group('ThemeProvider', () {
    test('default mode is system', () {
      final provider = ThemeProvider();

      expect(provider.themeMode, AppThemeMode.system);
      expect(provider.materialThemeMode, ThemeMode.system);
      expect(provider.themeModeString, 'System');
    });

    test('setThemeMode updates mode and strings', () {
      final provider = ThemeProvider();

      provider.setThemeMode(AppThemeMode.dark);
      expect(provider.themeMode, AppThemeMode.dark);
      expect(provider.materialThemeMode, ThemeMode.dark);
      expect(provider.themeModeString, 'Dark');

      provider.setThemeMode(AppThemeMode.light);
      expect(provider.materialThemeMode, ThemeMode.light);
      expect(provider.themeModeString, 'Light');
    });

    test('toggleTheme switches between dark and light', () {
      final provider = ThemeProvider();

      provider.setThemeMode(AppThemeMode.dark);
      provider.toggleTheme();
      expect(provider.themeMode, AppThemeMode.light);

      provider.toggleTheme();
      expect(provider.themeMode, AppThemeMode.dark);
    });
  });
}
