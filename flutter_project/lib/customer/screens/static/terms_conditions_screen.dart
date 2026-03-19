import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Terms & Conditions',
                style: theme.textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 8),
            
            Center(
              child: Text(
                'Last Updated: February 6, 2026',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              theme,
              '1. Acceptance of Terms',
              'By accessing and using ServiceHub, you accept and agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services.',
            ),
            
            _buildSection(
              theme,
              '2. Service Description',
              'ServiceHub is a platform that connects customers with verified service professionals for various home services. We act as an intermediary and do not directly provide the services.',
            ),
            
            _buildSection(
              theme,
              '3. User Eligibility',
              'You must be at least 18 years old to use our services. By using ServiceHub, you represent that you meet this age requirement and have the legal capacity to enter into these Terms.',
            ),
            
            _buildSection(
              theme,
              '4. User Account',
              '• You are responsible for maintaining the confidentiality of your account credentials\n'
              '• You agree to provide accurate and complete information\n'
              '• You are responsible for all activities that occur under your account\n'
              '• You must notify us immediately of any unauthorized use',
            ),
            
            _buildSection(
              theme,
              '5. Booking and Payments',
              '• All bookings are subject to availability\n'
              '• Prices displayed are inclusive of applicable taxes\n'
              '• Payment is due upon service completion\n'
              '• Cancellation policies apply as per the service terms\n'
              '• We reserve the right to refuse or cancel bookings',
            ),
            
            _buildSection(
              theme,
              '6. Service Provider Relationship',
              'Service providers on our platform are independent contractors. ServiceHub does not employ these professionals and is not responsible for their actions, quality of work, or any damages arising from their services.',
            ),
            
            _buildSection(
              theme,
              '7. User Conduct',
              'You agree not to:\n'
              '• Violate any laws or regulations\n'
              '• Impersonate others or provide false information\n'
              '• Harass, abuse, or harm service providers\n'
              '• Interfere with the platform\'s functionality\n'
              '• Use the service for unauthorized commercial purposes',
            ),
            
            _buildSection(
              theme,
              '8. Cancellation and Refunds',
              '• Cancellations are allowed before the service provider starts the job\n'
              '• Refunds are processed as per our refund policy\n'
              '• Processing time for refunds is 5-7 business days\n'
              '• Cancellation charges may apply in certain cases',
            ),
            
            _buildSection(
              theme,
              '9. Limitation of Liability',
              'ServiceHub shall not be liable for any indirect, incidental, special, or consequential damages arising from the use of our services. Our total liability is limited to the amount paid for the specific service in question.',
            ),
            
            _buildSection(
              theme,
              '10. Intellectual Property',
              'All content, trademarks, and intellectual property on the platform are owned by ServiceHub or its licensors. You may not use, reproduce, or distribute any content without our written permission.',
            ),
            
            _buildSection(
              theme,
              '11. Dispute Resolution',
              'Any disputes arising from these Terms shall be resolved through arbitration in accordance with Indian law. The jurisdiction shall be the courts of India.',
            ),
            
            _buildSection(
              theme,
              '12. Modifications',
              'We reserve the right to modify these Terms at any time. Changes will be effective upon posting. Continued use of the service constitutes acceptance of modified Terms.',
            ),
            
            _buildSection(
              theme,
              '13. Termination',
              'We may suspend or terminate your access to the service at any time for violations of these Terms or for any other reason deemed appropriate.',
            ),
            
            _buildSection(
              theme,
              '14. Contact Information',
              'For questions regarding these Terms and Conditions:\n'
              '• Email: legal@servicehub.com\n'
              '• Phone: +91 1800-XXX-XXXX\n'
              '• Address: ServiceHub Legal Department, India',
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using ServiceHub, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}