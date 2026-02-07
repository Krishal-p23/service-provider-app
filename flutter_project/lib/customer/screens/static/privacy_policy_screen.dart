import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Privacy Policy',
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
              '1. Introduction',
              'ServiceHub ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
            ),
            
            _buildSection(
              theme,
              '2. Information We Collect',
              'We collect information that you provide directly to us, including:\n'
              '• Personal identification information (name, email address, phone number)\n'
              '• Location data (to match you with nearby service providers)\n'
              '• Payment information (processed securely through third-party payment processors)\n'
              '• Service booking details and history\n'
              '• Reviews and ratings you provide\n'
              '• Device information and usage data',
            ),
            
            _buildSection(
              theme,
              '3. How We Use Your Information',
              'We use the collected information to:\n'
              '• Provide, maintain, and improve our services\n'
              '• Process your bookings and payments\n'
              '• Send you service updates and booking confirmations\n'
              '• Match you with appropriate service providers\n'
              '• Improve customer service and support\n'
              '• Prevent fraud and ensure platform security\n'
              '• Comply with legal obligations',
            ),
            
            _buildSection(
              theme,
              '4. Information Sharing',
              'We do not sell your personal information. We may share your information with:\n'
              '• Service providers who need it to perform services on our behalf\n'
              '• Verified professionals assigned to your bookings\n'
              '• Legal authorities when required by law\n'
              '• Business partners with your consent',
            ),
            
            _buildSection(
              theme,
              '5. Data Security',
              'We implement appropriate technical and organizational measures to protect your personal information. However, no method of transmission over the Internet is 100% secure, and we cannot guarantee absolute security.',
            ),
            
            _buildSection(
              theme,
              '6. Your Rights',
              'You have the right to:\n'
              '• Access your personal information\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Opt-out of marketing communications\n'
              '• Withdraw consent where applicable',
            ),
            
            _buildSection(
              theme,
              '7. Cookies and Tracking',
              'We use cookies and similar tracking technologies to track activity on our service and hold certain information to improve and analyze our service.',
            ),
            
            _buildSection(
              theme,
              '8. Children\'s Privacy',
              'Our service is not intended for users under the age of 18. We do not knowingly collect personal information from children under 18.',
            ),
            
            _buildSection(
              theme,
              '9. Changes to Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
            ),
            
            _buildSection(
              theme,
              '10. Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n'
              '• Email: privacy@servicehub.com\n'
              '• Phone: +91 1800-XXX-XXXX\n'
              '• Address: ServiceHub Headquarters, India',
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your privacy is important to us. We are committed to protecting your personal information.',
                      style: theme.textTheme.bodySmall,
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