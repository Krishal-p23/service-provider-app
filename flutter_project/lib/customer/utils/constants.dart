class AppConstants {
  // ============================================================================
  // APP INFORMATION
  // ============================================================================
  static const String appName = 'HomeServe Pro';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your trusted home services booking platform';

  // ============================================================================
  // API URLs (Mock - Replace with real backend URLs)
  // ============================================================================
  static const String baseUrl = 'https://api.homeservepro.com';
  static const String apiVersion = 'v1';

  // ============================================================================
  // PAGINATION & LIMITS
  // ============================================================================
  static const int itemsPerPage = 20;
  static const int searchResultsLimit = 50;
  static const int nearbyWorkersLimit = 20;

  // ============================================================================
  // DISTANCE & LOCATION
  // ============================================================================
  static const double defaultSearchRadius = 10.0; // kilometers
  static const double maxSearchRadius = 50.0; // kilometers
  static const double minSearchRadius = 1.0; // kilometers

  // ============================================================================
  // OTP & VERIFICATION
  // ============================================================================
  static const String mockOTP = '123456';
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;

  // ============================================================================
  // BOOKING STATUS
  // ============================================================================
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // ============================================================================
  // PAYMENT METHODS
  // ============================================================================
  static const String paymentCash = 'cash';
  static const String paymentUPI = 'upi';
  static const String paymentNetBanking = 'netbanking';
  static const String paymentWallet = 'wallet';

  // ============================================================================
  // PAYMENT STATUS
  // ============================================================================
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusRefunded = 'refunded';

  // ============================================================================
  // WALLET TRANSACTION TYPES
  // ============================================================================
  static const String transactionCredit = 'credit';
  static const String transactionDebit = 'debit';
  static const String transactionRefund = 'refund';

  // ============================================================================
  // USER ROLES
  // ============================================================================
  static const String roleCustomer = 'customer';
  static const String roleWorker = 'worker';

  // ============================================================================
  // RATING SYSTEM
  // ============================================================================
  static const int minRating = 1;
  static const int maxRating = 5;

  // ============================================================================
  // CONTACT INFORMATION
  // ============================================================================
  static const String supportEmail = 'support@homeservepro.com';
  static const String supportPhone = '+91-1800-123-4567';

  // ============================================================================
  // SOCIAL MEDIA (Optional)
  // ============================================================================
  static const String facebookUrl = 'https://facebook.com/homeservepro';
  static const String twitterUrl = 'https://twitter.com/homeservepro';
  static const String instagramUrl = 'https://instagram.com/homeservepro';

  // ============================================================================
  // LANGUAGES
  // ============================================================================
  static const String languageEnglish = 'English';
  static const String languageHindi = 'Hindi';
  static const List<String> availableLanguages = [
    languageEnglish,
    languageHindi,
  ];

  // ============================================================================
  // TIME SLOTS (for booking)
  // ============================================================================
  static const List<String> timeSlots = [
    '08:00 AM - 09:00 AM',
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '12:00 PM - 01:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
    '05:00 PM - 06:00 PM',
    '06:00 PM - 07:00 PM',
    '07:00 PM - 08:00 PM',
  ];

  // ============================================================================
  // SORT OPTIONS
  // ============================================================================
  static const String sortByDistanceAsc = 'distance_asc';
  static const String sortByDistanceDesc = 'distance_desc';
  static const String sortByRatingDesc = 'rating_desc';
  static const String sortByPriceAsc = 'price_asc';
  static const String sortByPriceDesc = 'price_desc';

  // ============================================================================
  // FILTER OPTIONS
  // ============================================================================
  static const String filterByAvailability = 'availability';
  static const String filterByRating = 'rating';
  static const String filterByDistance = 'distance';
  static const String filterByPrice = 'price';

  // ============================================================================
  // VALIDATION
  // ============================================================================
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int phoneNumberLength = 10;

  // ============================================================================
  // CACHE & STORAGE KEYS
  // ============================================================================
  static const String keyLoggedInUser = 'logged_in_user';
  static const String keyLoggedInWorker = 'logged_in_worker';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';

  // ============================================================================
  // ERROR MESSAGES
  // ============================================================================
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorInvalidOTP = 'Invalid OTP. Please try again.';
  static const String errorBookingFailed = 'Failed to create booking. Please try again.';
  static const String errorPaymentFailed = 'Payment failed. Please try again.';
  static const String errorLocationPermission = 'Location permission is required.';

  // ============================================================================
  // SUCCESS MESSAGES
  // ============================================================================
  static const String successRegistration = 'Registration successful!';
  static const String successLogin = 'Login successful!';
  static const String successBooking = 'Booking confirmed!';
  static const String successPayment = 'Payment completed successfully!';
  static const String successReview = 'Review submitted successfully!';

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Check if booking can be cancelled
  static bool canCancelBooking(String status) {
    return status == statusPending || status == statusConfirmed;
  }

  /// Check if payment is required
  static bool isPaymentRequired(String status) {
    return status == statusCompleted;
  }

  /// Get status display text
  static String getStatusDisplayText(String status) {
    switch (status) {
      case statusPending:
        return 'Pending';
      case statusConfirmed:
        return 'Confirmed';
      case statusInProgress:
        return 'In Progress';
      case statusCompleted:
        return 'Completed';
      case statusCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Get payment method display text
  static String getPaymentMethodDisplayText(String method) {
    switch (method) {
      case paymentCash:
        return 'Cash on Delivery';
      case paymentUPI:
        return 'UPI';
      case paymentNetBanking:
        return 'Net Banking';
      case paymentWallet:
        return 'Wallet';
      default:
        return method;
    }
  }
}
