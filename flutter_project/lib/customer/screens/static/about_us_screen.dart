import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_repair_service,
                  size: 80,
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Center(
              child: Text(
                'ServiceHub',
                style: theme.textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 8),
            
            Center(
              child: Text(
                'Your Trusted Service Partner',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              theme,
              'Our Mission',
              'At ServiceHub, we are committed to connecting customers with skilled and verified service professionals. Our mission is to make home services accessible, reliable, and affordable for everyone.',
            ),
            
            _buildSection(
              theme,
              'What We Offer',
              'We provide a wide range of home services including plumbing, electrical work, cleaning, carpentry, painting, AC repair, pest control, and appliance repair. All our service providers are thoroughly verified and experienced professionals.',
            ),
            
            _buildSection(
              theme,
              'Why Choose Us',
              '• Verified Professionals: All workers are background-checked and verified\n'
              '• Transparent Pricing: No hidden charges, clear pricing before booking\n'
              '• Quality Assurance: We ensure high-quality service delivery\n'
              '• Secure Payments: Multiple payment options with secure transactions\n'
              '• 24/7 Support: Our customer support team is always here to help',
            ),
            
            _buildSection(
              theme,
              'Our Vision',
              'We envision a future where finding reliable home services is as easy as a few taps on your phone. We are constantly working to expand our services and improve our platform to serve you better.',
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: Column(
                children: [
                  Text(
                    'Get in Touch',
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    theme,
                    Icons.email,
                    'support@servicehub.com',
                  ),
                  const SizedBox(height: 8),
                  _buildContactItem(
                    theme,
                    Icons.phone,
                    '+91 1800-XXX-XXXX',
                  ),
                  const SizedBox(height: 8),
                  _buildContactItem(
                    theme,
                    Icons.language,
                    'www.servicehub.com',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: Text(
                '© 2026 ServiceHub. All rights reserved.',
                style: theme.textTheme.bodySmall,
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
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}