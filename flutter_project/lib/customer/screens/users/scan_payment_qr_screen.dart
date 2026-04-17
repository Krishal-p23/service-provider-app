import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'payment_verification_screen.dart';

class ScanPaymentQrScreen extends StatefulWidget {
  const ScanPaymentQrScreen({super.key});

  @override
  State<ScanPaymentQrScreen> createState() => _ScanPaymentQrScreenState();
}

class _ScanPaymentQrScreenState extends State<ScanPaymentQrScreen> {
  final TextEditingController _qrController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isVerifying = false;

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _verifyQrData() async {
    if (_isVerifying) return;

    final raw = _qrController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste QR data first.')),
      );
      return;
    }

    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme != 'verify' || uri.host != 'payment') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid QR format.')));
      return;
    }

    final bookingId = int.tryParse(uri.queryParameters['bookingId'] ?? '');
    final scannedAmount = double.tryParse(uri.queryParameters['amount'] ?? '');

    if (bookingId == null || scannedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR data missing bookingId or amount.')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await _apiService.initialize();
      final bookingResult = await _apiService.getBookingById(bookingId);

      if (!mounted) return;

      if (bookingResult['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to verify booking amount.')),
        );
        return;
      }

      final bookingData = bookingResult['data'] as Map<String, dynamic>?;
      final serverAmount = (bookingData?['total_amount'] as num?)?.toDouble();

      if (serverAmount == null || serverAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid booking amount from server.')),
        );
        return;
      }

      if ((serverAmount - scannedAmount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'QR amount mismatch detected. Using booking amount Rs ${serverAmount.toStringAsFixed(0)}.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentVerificationScreen(
            bookingId: bookingId,
            amount: serverAmount,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Payment QR')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paste scanned QR payload',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Expected format: verify://payment?bookingId=123&amount=500',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _qrController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'verify://payment?bookingId=123&amount=500',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isVerifying ? null : _verifyQrData,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified),
                label: Text(
                  _isVerifying ? 'Verifying...' : 'Verify Payment QR',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  _qrController.text =
                      'verify://payment?bookingId=1001&amount=500';
                },
                child: const Text('Fill Demo QR Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
