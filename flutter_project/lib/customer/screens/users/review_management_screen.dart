import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/booking_provider.dart';
import '../../../providers/user_provider.dart';
import '../../models/review.dart';
import '../../models/worker.dart';
import '../../models/user.dart';

class ReviewManagementScreen extends StatefulWidget {
  final int bookingId;

  const ReviewManagementScreen({super.key, required this.bookingId});

  @override
  State<ReviewManagementScreen> createState() => _ReviewManagementScreenState();
}

class _ReviewManagementScreenState extends State<ReviewManagementScreen> {
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final serviceProvider = Provider.of<ServiceProvider>(
        context,
        listen: false,
      );
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      final booking = bookingProvider.getBookingById(widget.bookingId);

      if (booking == null) {
        throw Exception('Booking not found');
      }

      await serviceProvider.addReview(
        bookingId: widget.bookingId,
        userId: booking.userId,
        workerId: booking.workerId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _goBack() {
    Navigator.pop(context, false);
  }

  Widget _buildReviewForm(ThemeData theme, Worker? worker, User? workerUser) {
    return SingleChildScrollView(
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
              workerUser?.name ?? 'Worker',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 32),
          ],
          Text('How was your experience?', style: theme.textTheme.displaySmall),
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
    );
  }

  Widget _buildReviewDisplay(
    ThemeData theme,
    Review review,
    Worker? worker,
    User? workerUser,
  ) {
    return SingleChildScrollView(
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
              workerUser?.name ?? 'Worker',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 32),
          ],
          // Review Title
          Text('Your Review', style: theme.textTheme.displaySmall),
          const SizedBox(height: 24),
          // Star Rating Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                size: 36,
                color: Colors.amber,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            review.rating == 1
                ? 'Poor'
                : review.rating == 2
                ? 'Below Average'
                : review.rating == 3
                ? 'Average'
                : review.rating == 4
                ? 'Good'
                : 'Excellent',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Comment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(review.comment!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Date
          Text(
            'Reviewed on ${review.createdAt.toString().split(' ')[0]}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          // Back Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goBack,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Back to Bookings',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final booking = bookingProvider.getBookingById(widget.bookingId);
    final worker = booking != null
        ? serviceProvider.getWorkerById(booking.workerId)
        : null;
    final workerUser = booking != null
        ? serviceProvider.getWorkerUserByWorkerId(booking.workerId)
        : null;

    // Check if review already exists
    final existingReview = serviceProvider.getReviewForBooking(
      widget.bookingId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(existingReview != null ? 'Your Review' : 'Rate Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: existingReview != null
          ? _buildReviewDisplay(theme, existingReview, worker, workerUser)
          : _buildReviewForm(theme, worker, workerUser),
    );
  }
}
