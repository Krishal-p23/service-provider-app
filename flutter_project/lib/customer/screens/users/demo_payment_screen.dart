import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DemoPaymentScreen extends StatelessWidget {
  final int bookingId;
  final double amount;
  final String? customerName;
  final String? serviceName;

  const DemoPaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    this.customerName,
    this.serviceName,
  });

  String get _qrPayload =>
      'verify://payment?bookingId=$bookingId&amount=${amount.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Show Payment QR')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking #$bookingId',
                        style: theme.textTheme.titleMedium,
                      ),
                      if (customerName != null &&
                          customerName!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Customer: $customerName',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (serviceName != null &&
                          serviceName!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Service: $serviceName',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Amount: Rs ${amount.toStringAsFixed(0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: QrImageView(
                    data: _qrPayload,
                    size: 240,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SelectableText(
                _qrPayload,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Ask customer to scan this QR from My Bookings and confirm payment.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
