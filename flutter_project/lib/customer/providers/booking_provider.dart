import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/payment.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Booking> _bookings = [];
  final Map<int, Payment> _paymentsByBooking = {};
  int? _loadedUserId;
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> fetchUserBookings(int userId) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.initialize();
      final result = await _apiService.getUserBookings(userId);
      if (result['success'] == true) {
        _bookings = (result['data'] as List)
            .map((item) => Booking.fromJson(item as Map<String, dynamic>))
            .toList();
        _loadedUserId = userId;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get bookings for a specific user
  List<Booking> getUserBookings(int userId) {
    if (_loadedUserId != userId && !_isLoading) {
      fetchUserBookings(userId);
    }
    return _bookings.where((b) => b.userId == userId).toList();
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
    await _apiService.initialize();
    final result = await _apiService.createBooking(
      userId: userId,
      workerId: workerId,
      serviceId: serviceId,
      scheduledDate: scheduledDate,
      totalAmount: totalAmount,
    );

    if (result['success'] != true) {
      throw Exception('Failed to create booking');
    }

    final booking = Booking.fromJson(result['data'] as Map<String, dynamic>);
    _bookings = [booking, ..._bookings];
    notifyListeners();
    return booking;
  }

  // Update booking status
  Future<void> updateBookingStatus(int bookingId, String status) async {
    await _apiService.initialize();
    final result = await _apiService.updateBookingStatus(bookingId, status);
    if (result['success'] == true) {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx >= 0) {
        _bookings[idx] = _bookings[idx].copyWith(status: status);
        notifyListeners();
      }
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(int bookingId) async {
    final booking = getBookingById(bookingId);
    if (booking != null &&
        (booking.status == 'pending' || booking.status == 'confirmed')) {
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
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch,
      bookingId: bookingId,
      paymentMethod: paymentMethod,
      paymentStatus: 'completed',
      transactionId: transactionId,
      paidAt: DateTime.now(),
    );

    _paymentsByBooking[bookingId] = payment;
    notifyListeners();
  }

  // Get payment for booking
  Payment? getPaymentForBooking(int bookingId) {
    return _paymentsByBooking[bookingId];
  }

  Booking? getBookingById(int bookingId) {
    try {
      return _bookings.firstWhere((b) => b.id == bookingId);
    } catch (_) {
      return null;
    }
  }

  Future<Booking?> fetchBookingById(int bookingId) async {
    await _apiService.initialize();
    final result = await _apiService.getBookingById(bookingId);

    if (result['success'] != true) {
      return null;
    }

    final booking = Booking.fromJson(result['data'] as Map<String, dynamic>);
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      _bookings[idx] = booking;
    } else {
      _bookings.add(booking);
    }
    notifyListeners();
    return booking;
  }

  // Verify OTP (mock implementation)
  bool verifyOTP(String otp) {
    // Mock OTP verification - always returns true for '123456'
    return otp == '123456';
  }
}
