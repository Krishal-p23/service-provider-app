import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.getSurfaceColor(context),
        foregroundColor: AppTheme.getTextColor(context),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Display',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.workerPrimaryColor,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.getTextColor(
                        context,
                        secondary: true,
                      ).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildThemeOption(
                        context,
                        'Light Mode',
                        Icons.light_mode_outlined,
                        AppThemeMode.light,
                        themeProvider.themeMode == AppThemeMode.light,
                        () => themeProvider.setThemeMode(AppThemeMode.light),
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.getTextColor(
                          context,
                          secondary: true,
                        ).withOpacity(0.2),
                      ),
                      _buildThemeOption(
                        context,
                        'Dark Mode',
                        Icons.dark_mode_outlined,
                        AppThemeMode.dark,
                        themeProvider.themeMode == AppThemeMode.dark,
                        () => themeProvider.setThemeMode(AppThemeMode.dark),
                      ),
                      Divider(
                        height: 1,
                        color: AppTheme.getTextColor(
                          context,
                          secondary: true,
                        ).withOpacity(0.2),
                      ),
                      _buildThemeOption(
                        context,
                        'System Default',
                        Icons.settings_outlined,
                        AppThemeMode.system,
                        themeProvider.themeMode == AppThemeMode.system,
                        () => themeProvider.setThemeMode(AppThemeMode.system),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Current Theme Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.workerPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.workerPrimaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: AppTheme.workerPrimaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Currently using: ${themeProvider.isDarkMode ? 'Dark' : 'Light'} Mode',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.getTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    AppThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: AppTheme.getSurfaceColor(context),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.workerPrimaryColor
                    : AppTheme.getTextColor(context, secondary: true),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
              ),
              Radio<AppThemeMode>(
                value: mode,
                groupValue: isSelected ? mode : null,
                onChanged: (_) => onTap(),
                activeColor: AppTheme.workerPrimaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
