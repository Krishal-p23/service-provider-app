import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/theme_provider.dart';
import '../../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  Future<void> _logout(BuildContext context) async {
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
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser != null) {
        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Call delete account API
        final success = await userProvider.deleteAccount(currentUser.id);

        // Close loading dialog
        if (mounted) {
          Navigator.pop(context);
        }

        if (success && mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Navigate to onboarding
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        } else if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userProvider.error ?? 'Failed to delete account',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLarge,
              AppTheme.spacingLarge,
              AppTheme.spacingLarge,
              AppTheme.spacingSmall,
            ),
            child: Text(
              'Appearance',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.setThemeMode(
                value ? AppThemeMode.dark : AppThemeMode.light,
              );
            },
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.primaryColor,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLarge,
              AppTheme.spacingLarge,
              AppTheme.spacingLarge,
              AppTheme.spacingSmall,
            ),
            child: Text(
              'Notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive booking and service updates'),
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            secondary: Icon(Icons.notifications, color: theme.primaryColor),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLarge,
              AppTheme.spacingLarge,
              AppTheme.spacingLarge,
              AppTheme.spacingSmall,
            ),
            child: Text(
              'Privacy & Security',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.lock_outline, color: theme.primaryColor),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to privacy policy screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy Policy screen - Coming soon'),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.description_outlined,
              color: theme.primaryColor,
            ),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to terms screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms & Conditions screen - Coming soon'),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.primaryColor),
            title: const Text('About Us'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to about screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('About Us screen - Coming soon'),
                ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLarge,
              AppTheme.spacingLarge,
              AppTheme.spacingLarge,
              AppTheme.spacingSmall,
            ),
            child: Text(
              'Account',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.warningColor),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
            title: const Text('Delete Account'),
            onTap: () => _deleteAccount(context),
          ),
          const SizedBox(height: AppTheme.spacingXXLarge),
          Center(
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXXLarge),
        ],
      ),
    );
  }
}