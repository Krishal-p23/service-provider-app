import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Booking> _bookings = [];
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
    return userBookings
        .where(
          (b) => b.status == 'in_progress' || b.status == 'awaiting_payment',
        )
        .toList();
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
      final data = result['data'];
      final message = data is Map<String, dynamic>
          ? (data['message'] ?? data['error'] ?? 'Failed to create booking')
                .toString()
          : 'Failed to create booking';
      throw Exception(message);
    }

    final booking = Booking.fromJson(result['data'] as Map<String, dynamic>);
    _bookings = [booking, ..._bookings];
    notifyListeners();
    return booking;
  }

  Future<Set<int>> getWorkerUnavailableHours({
    required int workerId,
    required DateTime date,
  }) async {
    await _apiService.initialize();
    final result = await _apiService.getWorkerAvailability(
      workerId: workerId,
      date: date,
    );

    if (result['success'] != true) {
      return <int>{};
    }

    final data = result['data'] as Map<String, dynamic>;
    final hours = (data['unavailable_hours'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => item is int ? item : int.tryParse(item.toString()) ?? -1)
        .where((item) => item >= 0 && item <= 23)
        .toSet();

    return hours;
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
    // TODO: Replace placeholder with backend payment confirmation endpoint call.
    await _recordPaymentIfAvailable(bookingId);
    await updateBookingStatus(bookingId, 'completed');
  }

  // Process payment for booking
  Future<void> processPayment({
    required int bookingId,
    required String paymentMethod,
    required String transactionId,
    String? paymentStatus,
    bool useWallet = false,
    int? userId,
  }) async {
    await _apiService.initialize();
    final result = await _apiService.confirmPayment(
      bookingId: bookingId,
      paymentMethod: paymentMethod,
      transactionRef: transactionId,
      paymentStatus: paymentStatus,
      useWallet: useWallet,
      userId: userId,
    );

    if (result['success'] != true) {
      final data = result['data'];
      final message = data is Map<String, dynamic>
          ? (data['message'] ?? data['error'] ?? 'Failed to confirm payment')
                .toString()
          : 'Failed to confirm payment';
      throw Exception(message);
    }

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      _bookings[idx] = _bookings[idx].copyWith(status: 'completed');
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> confirmCompletion({
    required int bookingId,
    int? userId,
  }) async {
    await _apiService.initialize();
    final result = await _apiService.confirmBookingCompletion(
      bookingId: bookingId,
      userId: userId,
    );

    final data = result['data'];
    final code = result['code']?.toString().toUpperCase();
    if (result['statusCode'] == 402 || code == 'PAYMENT_REQUIRED') {
      final amount = data is Map<String, dynamic>
          ? (data['amount'] as num?)?.toDouble() ?? 0
          : 0.0;
      return {
        'completed': false,
        'paymentRequired': true,
        'bookingId': bookingId,
        'amount': amount,
      };
    }

    if (result['success'] != true) {
      final message =
          result['message']?.toString() ??
          (data is Map<String, dynamic>
              ? (data['message'] ??
                        data['error'] ??
                        'Failed to confirm completion')
                    .toString()
              : 'Failed to confirm completion');
      throw Exception(message);
    }

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      _bookings[idx] = _bookings[idx].copyWith(status: 'completed');
      notifyListeners();
    }

    return {
      'completed': true,
      'paymentRequired': false,
      'bookingId': bookingId,
    };
  }

  Future<void> _recordPaymentIfAvailable(int bookingId) async {
    // TODO: Wire to backend payment record API when endpoint is available.
    // This placeholder keeps completion flow centralized until Part 2 payment APIs are implemented.
    return;
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

  // Verify booking OTP against backend and activate the job when valid.
  Future<void> verifyBookingOtp({
    required int bookingId,
    required String otp,
  }) async {
    await _apiService.initialize();
    final result = await _apiService.verifyJobOTP(
      bookingId: bookingId,
      otp: otp,
    );

    if (result['success'] != true) {
      final data = result['data'];
      final message = data is Map<String, dynamic>
          ? (data['message'] ?? data['error'] ?? 'Invalid OTP').toString()
          : 'Invalid OTP';
      throw Exception(message);
    }

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx >= 0) {
      _bookings[idx] = _bookings[idx].copyWith(status: 'in_progress');
      notifyListeners();
    }
  }
}
