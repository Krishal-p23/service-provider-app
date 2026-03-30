import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/booking_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../../providers/user_provider.dart';
import '../../services/api_service.dart';
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
  final ApiService _apiService = ApiService();
  final TextEditingController _transactionRefController =
      TextEditingController();

  bool _isProcessing = false;
  bool _isLoading = true;
  String? _upiString;
  String? _bookingStatus;
  String? _error;
  double _walletBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  @override
  void dispose() {
    _transactionRefController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _apiService.initialize();
      final qrResult = await _apiService.getPaymentQr(widget.bookingId);
      if (qrResult['success'] != true) {
        throw Exception(
          qrResult['data']?['message'] ?? 'Failed to load payment QR',
        );
      }

      final qrData = qrResult['data'] as Map<String, dynamic>;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.id;
      if (userId != null) {
        final walletProvider = Provider.of<WalletProvider>(
          context,
          listen: false,
        );
        _walletBalance = await walletProvider.getUserBalance(userId);
      }

      if (!mounted) return;

      setState(() {
        _upiString = qrData['upi_string']?.toString();
        _bookingStatus = qrData['booking_status']?.toString();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _confirmPayment({
    required String paymentMethod,
    String? paymentStatus,
    bool useWallet = false,
  }) async {
    setState(() => _isProcessing = true);

    try {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );

      final userId = Provider.of<UserProvider>(
        context,
        listen: false,
      ).currentUser?.id;
      final transactionId = _transactionRefController.text.trim().isNotEmpty
          ? _transactionRefController.text.trim()
          : 'TXN${DateTime.now().millisecondsSinceEpoch}';

      await bookingProvider.processPayment(
        bookingId: widget.bookingId,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        paymentStatus: paymentStatus,
        useWallet: useWallet,
        userId: userId,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RateWorkerScreen(bookingId: widget.bookingId),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            paymentMethod == 'COD'
                ? 'Booking completed. Collect cash physically from customer.'
                : 'Payment confirmed successfully!',
          ),
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
    final canPayNow =
        _bookingStatus == null || _bookingStatus == 'awaiting_payment';
    final canWalletPay = _walletBalance >= widget.amount;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
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
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${(_bookingStatus ?? 'unknown').replaceAll('_', ' ')}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_upiString != null) ...[
                    Text('UPI QR Payment', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: QrImageView(
                          data: _upiString!,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Open any UPI app, scan this QR, and pay ₹${widget.amount.toStringAsFixed(0)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _transactionRefController,
                      decoration: const InputDecoration(
                        labelText: 'Transaction Ref / UTR (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

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
                            canPayNow
                                ? 'Payment is enabled because booking is awaiting payment.'
                                : 'Payment is not available until worker marks the job done.',
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
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isProcessing || !canPayNow)
                            ? null
                            : () => _confirmPayment(paymentMethod: 'UPI'),
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
                                'I have paid',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (canWalletPay)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: (_isProcessing || !canPayNow)
                              ? null
                              : () => _confirmPayment(
                                  paymentMethod: 'WALLET',
                                  useWallet: true,
                                ),
                          child: Text(
                            'Pay with Wallet (₹${_walletBalance.toStringAsFixed(0)})',
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: (_isProcessing || !canPayNow)
                            ? null
                            : () => _confirmPayment(
                                paymentMethod: 'COD',
                                paymentStatus: 'pending',
                              ),
                        child: const Text('Cash on Delivery'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
