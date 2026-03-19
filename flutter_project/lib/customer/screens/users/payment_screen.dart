import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/payment_option_card.dart';
import 'rate_worker_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'COD';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'COD',
      'title': 'Cash on Delivery',
      'subtitle': 'Pay with cash after job completion',
      'icon': Icons.money,
    },
    {
      'id': 'UPI',
      'title': 'UPI Payment',
      'subtitle': 'Pay using UPI apps',
      'icon': Icons.qr_code_scanner,
    },
    {
      'id': 'NETBANKING',
      'title': 'Net Banking',
      'subtitle': 'Pay through your bank',
      'icon': Icons.account_balance,
    },
  ];

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // Generate mock transaction ID
      final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      
      // Process payment
      await bookingProvider.processPayment(
        bookingId: widget.bookingId,
        paymentMethod: _selectedPaymentMethod,
        transactionId: transactionId,
      );

      await bookingProvider.completeBooking(widget.bookingId);

      if (!mounted) return;

      // Navigate to rating screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RateWorkerScreen(
            bookingId: widget.bookingId,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Total Amount',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${widget.amount.toStringAsFixed(0)}',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Select Payment Method',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            
            // Payment Options
            ..._paymentMethods.map((method) => PaymentOptionCard(
              title: method['title'],
              subtitle: method['subtitle'],
              icon: method['icon'],
              isSelected: _selectedPaymentMethod == method['id'],
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = method['id'];
                });
              },
            )).toList(),
            
            const SizedBox(height: 24),
            
            // Security Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment is 100% secure and encrypted',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Pay ₹${widget.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}