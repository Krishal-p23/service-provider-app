import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/worker_provider.dart';
import '../../customer/screens/onboarding_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final workerProvider = Provider.of<WorkerProvider>(
        context,
        listen: false,
      );
      await workerProvider.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          (route) => false,
        );
      }
    }
  }

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

                // Notifications Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.workerPrimaryColor,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text(
                    'Get alerts for new bookings and updates',
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  secondary: const Icon(Icons.notifications_outlined),
                ),
                const SizedBox(height: 24),

                // Privacy & Legal Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Privacy & Legal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.workerPrimaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms & Conditions'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsConditionsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Service Provider App',
                      applicationVersion: '1.0.0',
                      children: const [
                        Text('Worker app settings and profile management.'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Account Actions
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.workerPrimaryColor,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                  title: const Text('Logout'),
                  onTap: _logout,
                ),
                const SizedBox(height: 12),

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
