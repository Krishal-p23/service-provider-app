import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
              'Acceptance of Terms',
              'By using this application, you agree to these Terms & Conditions. If you do not agree, please do not use this application.',
            ),
            _buildSection(
              context,
              'User Responsibilities',
              'As a service provider, you agree to:\n'
                  '• Provide accurate information\n'
                  '• Maintain professional conduct\n'
                  '• Honor all bookings and commitments\n'
                  '• respect customer privacy\n'
                  '• Comply with all applicable laws',
            ),
            _buildSection(
              context,
              'Service Booking',
              'Services are booked through the application with confirmed appointment times. Cancellations must be made with appropriate notice as per policy.',
            ),
            _buildSection(
              context,
              'Payment Terms',
              'Payment is processed through our secure payment gateway. Service fees and commissions apply as per the rate card shown in the application.',
            ),
            _buildSection(
              context,
              'Ratings and Reviews',
              'Ratings and reviews are essential for service quality. All reviews should be honest and professional. Inappropriate reviews may result in account suspension.',
            ),
            _buildSection(
              context,
              'Account Suspension',
              'We reserve the right to suspend or terminate accounts that violate these terms, engage in fraudulent activity, or provide poor service.',
            ),
            _buildSection(
              context,
              'Limitation of Liability',
              'Our application is provided "as is" without warranties. We are not liable for indirect or consequential damages resulting from service provision.',
            ),
            _buildSection(
              context,
              'Modifications',
              'We reserve the right to modify these terms at any time. Continued use of the application constitutes acceptance of modified terms.',
            ),
            _buildSection(
              context,
              'Governing Law',
              'These terms are governed by applicable local laws and regulations.',
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
