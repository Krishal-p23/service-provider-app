import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import 'payment_screen.dart';

class OtpJobCompletionScreen extends StatefulWidget {
  final int bookingId;

  const OtpJobCompletionScreen({super.key, required this.bookingId});

  @override
  State<OtpJobCompletionScreen> createState() => _OtpJobCompletionScreenState();
}

class _OtpJobCompletionScreenState extends State<OtpJobCompletionScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter OTP')));
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      await bookingProvider.verifyBookingOtp(
        bookingId: widget.bookingId,
        otp: _otpController.text.trim(),
      );

      var booking = bookingProvider.getBookingById(widget.bookingId);
      booking ??= await bookingProvider.fetchBookingById(widget.bookingId);
      if (booking == null) {
        throw Exception('Booking not found');
      }
      final resolvedBooking = booking;

      if (!mounted) return;

      // Navigate to payment screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            bookingId: widget.bookingId,
            amount: resolvedBooking.totalAmount,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Job Completion')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: theme.primaryColor),
            const SizedBox(height: 32),

            Text('Enter OTP', style: theme.textTheme.displayLarge),
            const SizedBox(height: 12),

            Text(
              'Enter the OTP provided by the service provider to confirm job completion',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // OTP Input
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge,
              decoration: InputDecoration(
                hintText: '000000',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 32),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Verify & Continue',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
