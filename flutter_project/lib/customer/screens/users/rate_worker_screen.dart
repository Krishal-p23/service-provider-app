import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/mock_data.dart';
import 'package:flutter_project/customer/screens/users/booking_status_screen.dart';

class RateWorkerScreen extends StatefulWidget {
  final int bookingId;

  const RateWorkerScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<RateWorkerScreen> createState() => _RateWorkerScreenState();
}

class _RateWorkerScreenState extends State<RateWorkerScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final booking = MockDatabase.getBookingById(widget.bookingId);
      
      if (booking == null) {
        throw Exception('Booking not found');
      }

      await serviceProvider.addReview(
        bookingId: widget.bookingId,
        userId: booking.userId,
        workerId: booking.workerId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );

      if (!mounted) return;

      // Navigate to bookings screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const BookingStatusScreen(),
        ),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _skipReview() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const BookingStatusScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booking = MockDatabase.getBookingById(widget.bookingId);
    final worker = booking != null ? MockDatabase.getWorkerById(booking.workerId) : null;
    final workerUser = worker != null ? MockDatabase.getUserById(worker.userId) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Service'),
        actions: [
          TextButton(
            onPressed: _skipReview,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Worker Info
            if (worker != null) ...[
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: worker.profilePhoto != null
                    ? NetworkImage(worker.profilePhoto!)
                    : null,
                child: worker.profilePhoto == null
                    ? Icon(Icons.person, size: 50, color: theme.primaryColor)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                workerUser?.name ?? 'Worker ${worker.id}',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 32),
            ],
            
            Text(
              'How was your experience?',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 48,
                  ),
                  color: Colors.amber,
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                _rating == 1
                    ? 'Poor'
                    : _rating == 2
                        ? 'Below Average'
                        : _rating == 3
                            ? 'Average'
                            : _rating == 4
                                ? 'Good'
                                : 'Excellent',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 32),
            
            // Comment TextField
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit Review', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}