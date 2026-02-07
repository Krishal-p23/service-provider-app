import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text('Email Support', style: theme.textTheme.displaySmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('support@serviceapp.com'),
                  const SizedBox(height: 8),
                  const Text('We respond within 24 hours'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text('Phone Support', style: theme.textTheme.displaySmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('+91 1800-XXX-XXXX'),
                  const SizedBox(height: 8),
                  const Text('Mon-Sat: 9:00 AM - 6:00 PM'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chat, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Text('Live Chat', style: theme.textTheme.displaySmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Chat with our support team'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chat feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble),
                    label: const Text('Start Chat'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Frequently Asked Questions', style: theme.textTheme.displaySmall),
          const SizedBox(height: 12),
          _buildFAQItem(
            context,
            'How do I book a service?',
            'Browse services, select a provider, choose date/time, and confirm booking.',
          ),
          _buildFAQItem(
            context,
            'How do I cancel a booking?',
            'Go to My Bookings, select the booking, and tap Cancel. Cancellation is available until the worker starts the job.',
          ),
          _buildFAQItem(
            context,
            'What payment methods are accepted?',
            'We accept Cash on Delivery, UPI, and Net Banking.',
          ),
          _buildFAQItem(
            context,
            'How do refunds work?',
            'Refunds are processed within 5-7 business days to your original payment method or wallet.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(question),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}