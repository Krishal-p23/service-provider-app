import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../utils/mock_data.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  BookingProvider() {
    _loadBookings();
  }

  void _loadBookings() {
    _bookings = MockDatabase.bookings;
    notifyListeners();
  }

  // Get bookings for a specific user
  List<Booking> getUserBookings(int userId) {
    return MockDatabase.getBookingsByUserId(userId);
  }

  // Get bookings by status
  List<Booking> getBookingsByStatus(int userId, String status) {
    final userBookings = getUserBookings(userId);
    return userBookings.where((b) => b.status == status).toList();
  }

  // Get upcoming bookings
  List<Booking> getUpcomingBookings(int userId) {
    final userBookings = getUserBookings(userId);
    return userBookings
        .where((b) => b.status == 'pending' || b.status == 'confirmed')
        .toList();
  }

  // Get ongoing bookings
  List<Booking> getOngoingBookings(int userId) {
    final userBookings = getUserBookings(userId);
    return userBookings.where((b) => b.status == 'in_progress').toList();
  }

  // Get completed bookings
  List<Booking> getCompletedBookings(int userId) {
    final userBookings = getUserBookings(userId);
    return userBookings.where((b) => b.status == 'completed').toList();
  }

  // Create new booking
  Future<Booking> createBooking({
    required int userId,
    required int workerId,
    required int serviceId,
    required DateTime scheduledDate,
    required double totalAmount,
  }) async {
    final bookingId = MockDatabase.generateId(MockDatabase.bookings);
    
    final booking = Booking(
      id: bookingId,
      userId: userId,
      workerId: workerId,
      serviceId: serviceId,
      scheduledDate: scheduledDate,
      status: 'pending',
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
    );

    MockDatabase.addBooking(booking);
    _loadBookings();
    
    return booking;
  }

  // Update booking status
  Future<void> updateBookingStatus(int bookingId, String status) async {
    final booking = MockDatabase.getBookingById(bookingId);
    if (booking != null) {
      final updatedBooking = Booking(
        id: booking.id,
        userId: booking.userId,
        workerId: booking.workerId,
        serviceId: booking.serviceId,
        scheduledDate: booking.scheduledDate,
        status: status,
        totalAmount: booking.totalAmount,
        createdAt: booking.createdAt,
      );
      
      MockDatabase.updateBooking(updatedBooking);
      _loadBookings();
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(int bookingId) async {
    final booking = MockDatabase.getBookingById(bookingId);
    if (booking != null && (booking.status == 'pending' || booking.status == 'confirmed')) {
      await updateBookingStatus(bookingId, 'cancelled');
      return true;
    }
    return false;
  }

  // Mark booking as completed
  Future<void> completeBooking(int bookingId) async {
    await updateBookingStatus(bookingId, 'completed');
  }

  // Process payment for booking
  Future<void> processPayment({
    required int bookingId,
    required String paymentMethod,
    required String transactionId,
  }) async {
    final paymentId = MockDatabase.generateId(MockDatabase.payments);
    
    final payment = Payment(
      id: paymentId,
      bookingId: bookingId,
      paymentMethod: paymentMethod,
      paymentStatus: 'completed',
      transactionId: transactionId,
      paidAt: DateTime.now(),
    );

    MockDatabase.addPayment(payment);
    notifyListeners();
  }

  // Get payment for booking
  Payment? getPaymentForBooking(int bookingId) {
    return MockDatabase.getPaymentByBookingId(bookingId);
  }

  // Verify OTP (mock implementation)
  bool verifyOTP(String otp) {
    // Mock OTP verification - always returns true for '123456'
    return otp == '123456';
  }
}