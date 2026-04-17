import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../../providers/user_provider.dart';
import 'rate_worker_screen.dart';

class PaymentVerificationScreen extends StatefulWidget {
  final int bookingId;
  final double amount;

  const PaymentVerificationScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<PaymentVerificationScreen> createState() =>
      _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  bool _isSubmitting = false;

  Future<void> _confirmPayment() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await bookingProvider.confirmCompletion(
        bookingId: widget.bookingId,
        userId: userProvider.currentUser?.id,
        amount: widget.amount,
      );

      if (!mounted) return;

      if (userProvider.currentUser != null) {
        await bookingProvider.fetchUserBookings(userProvider.currentUser!.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment verified and booking completed.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to review screen instead of going back
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RateWorkerScreen(bookingId: widget.bookingId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Payment')),
      body: SafeArea(
        child: Padding(
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
                        'Booking #${widget.bookingId}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payable Amount',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            'Rs ${widget.amount.toStringAsFixed(0)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Confirm only after you have paid the worker.',
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm Payment & Complete Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
