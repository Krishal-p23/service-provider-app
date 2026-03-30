import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/service_provider.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/booking_card.dart';
import 'rate_worker_screen.dart';
import 'review_management_screen.dart';
import 'payment_screen.dart';

class BookingStatusScreen extends StatefulWidget {
  const BookingStatusScreen({super.key});

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshBookings();
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _refreshBookings();
    });
  }

  Future<void> _refreshBookings() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final currentUser = userProvider.currentUser;
    if (currentUser == null) {
      return;
    }
    await bookingProvider.fetchUserBookings(currentUser.id);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelBooking(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final bookingProvider = Provider.of<BookingProvider>(
        context,
        listen: false,
      );
      final success = await bookingProvider.cancelBooking(bookingId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot cancel booking at this stage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: const Center(child: Text('Please log in to view bookings')),
      );
    }

    final upcomingBookings = bookingProvider.getUpcomingBookings(
      currentUser.id,
    );
    final ongoingBookings = bookingProvider.getOngoingBookings(currentUser.id);
    final completedBookings = bookingProvider.getCompletedBookings(
      currentUser.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(upcomingBookings, 'upcoming'),
          _buildBookingList(ongoingBookings, 'ongoing'),
          _buildBookingList(completedBookings, 'completed'),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<dynamic> bookings, String type) {
    final bookingProvider = Provider.of<BookingProvider>(
      context,
      listen: false,
    );
    final serviceProvider = Provider.of<ServiceProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'No $type bookings',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final worker = serviceProvider.getWorkerById(booking.workerId);
        final workerUser = serviceProvider.getWorkerUserByWorkerId(
          booking.workerId,
        );
        final service = serviceProvider.getServiceById(booking.serviceId);

        // Check if review exists for completed bookings
        final hasReview = type == 'completed'
            ? serviceProvider.getReviewForBooking(booking.id) != null
            : false;

        return BookingCard(
          booking: booking,
          workerName: workerUser?.name ?? 'Worker ${booking.workerId}',
          serviceName: service?.serviceName ?? 'Service',
          workerPhoto: worker?.profilePhoto,
          hasReview: hasReview,
          onTap: () {
            // Navigate to booking details
          },
          onCancel: type == 'upcoming'
              ? () => _cancelBooking(booking.id)
              : null,
          onComplete: type == 'ongoing'
              ? () {
                  if (booking.status == 'awaiting_payment') {
                    final userId = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).currentUser?.id;
                    bookingProvider
                        .confirmCompletion(
                          bookingId: booking.id,
                          userId: userId,
                        )
                        .then((result) {
                          if (!context.mounted) return;
                          final paymentRequired =
                              result['paymentRequired'] == true;
                          if (paymentRequired) {
                            final amount =
                                (result['amount'] as num?)?.toDouble() ??
                                booking.totalAmount;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  bookingId: booking.id,
                                  amount: amount,
                                ),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please complete payment to finish this job.',
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RateWorkerScreen(bookingId: booking.id),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking completed successfully.'),
                            ),
                          );
                        })
                        .catchError((e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('Exception: ', ''),
                              ),
                            ),
                          );
                        });
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Payment is enabled after worker marks job done.',
                      ),
                    ),
                  );
                }
              : null,
          onPayNow: null,
          onRate: type == 'completed' && !hasReview
              ? () async {
                  final submitted = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReviewManagementScreen(bookingId: booking.id),
                    ),
                  );
                  if (!context.mounted) return;
                  if (submitted == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your feedback!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              : null,
        );
      },
    );
  }
}
