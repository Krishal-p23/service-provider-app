import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppTheme.getSurfaceColor(context),
        foregroundColor: AppTheme.getTextColor(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Introduction',
              'This Privacy Policy governs the manner in which our application collects, uses, and protects user information.',
            ),
            _buildSection(
              context,
              'Information Collection',
              'We collect information you provide directly, including:\n'
                  '• Profile information (name, phone, email)\n'
                  '• Location data (with your permission)\n'
                  '• Service history and preferences\n'
                  '• Payment information',
            ),
            _buildSection(
              context,
              'Use of Information',
              'We use collected information to:\n'
                  '• Provide and improve our services\n'
                  '• Process bookings and payments\n'
                  '• Send notifications and updates\n'
                  '• Analyze usage patterns\n'
                  '• Comply with legal obligations',
            ),
            _buildSection(
              context,
              'Data Security',
              'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, or disclosure.',
            ),
            _buildSection(
              context,
              'Third-Party Sharing',
              'We do not sell or share your personal information with third parties without your consent, except as required by law or for service provision.',
            ),
            _buildSection(
              context,
              'Your Rights',
              'You have the right to:\n'
                  '• Access your personal data\n'
                  '• Request data correction\n'
                  '• Request data deletion\n'
                  '• Opt-out of communications',
            ),
            _buildSection(
              context,
              'Contact Us',
              'If you have privacy concerns, please contact us through the Help & Support section.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.workerPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextColor(context, secondary: true),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
