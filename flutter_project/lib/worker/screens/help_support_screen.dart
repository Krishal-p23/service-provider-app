import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
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
              'Frequently Asked Questions',
              'Q: How do I update my profile?\n'
                  'A: Go to Account > Edit Profile to update your personal information.\n\n'
                  'Q: How are my earnings calculated?\n'
                  'A: Earnings are based on completed services minus platform commission. View your earnings in the Stats section.\n\n'
                  'Q: Can I cancel a booking?\n'
                  'A: Yes, you can cancel bookings at least 2 hours before the scheduled time. Late cancellations may incur penalties.\n\n'
                  'Q: How do I get verified?\n'
                  'A: Complete your profile with all required documents and information. Our team will review and approve your verification.',
            ),
            _buildSection(
              context,
              'Account Management',
              '• Update Profile: Edit your name, phone, email\n'
                  '• Manage Services: Add/remove services you offer\n'
                  '• Bank Details: Add payment account information\n'
                  '• Verification: Upload required documents',
            ),
            _buildSection(
              context,
              'Bookings & Services',
              '• View Bookings: Check all scheduled jobs\n'
                  '• Accept/Reject: Manage booking requests\n'
                  '• Track Progress: View current service status\n'
                  '• Mark Complete: Finish services and get paid',
            ),
            _buildSection(
              context,
              'Payments & Earnings',
              '• View Earnings: Check your total earnings\n'
                  '• Payment History: See all transactions\n'
                  '• Withdrawal: Request payment to your bank\n'
                  '• Support: Contact support for payment issues',
            ),
            _buildSection(
              context,
              'Getting In Touch',
              'If you need further assistance:\n'
                  '• Email: support@serviceapp.com\n'
                  '• Phone: 1-800-SERVICE (1-800-737-8423)\n'
                  '• Live Chat: Available in the app\n'
                  '• Support Hours: 9 AM - 9 PM, Monday to Sunday',
            ),
            _buildSection(
              context,
              'Common Issues & Solutions',
              '1. Not receiving bookings?\n'
                  '   - Check your availability settings\n'
                  '   - Ensure location is enabled\n'
                  '   - Verify profile is complete\n\n'
                  '2. Payment not received?\n'
                  '   - Check your bank details\n'
                  '   - Verify account verification status\n'
                  '   - Contact support if issue persists\n\n'
                  '3. Low ratings?\n'
                  '   - Provide better service quality\n'
                  '   - Communicate clearly with customers\n'
                  '   - Be punctual and professional',
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
