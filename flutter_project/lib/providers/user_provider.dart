import 'package:flutter/material.dart';
import '../customer/models/user.dart';
import '../customer/models/user_location.dart';
import '../customer/models/review.dart';
import '../customer/services/api_service.dart';

/// UserProvider - Manages customer (USER role) authentication and state
/// Communicates ONLY via REST API, no direct database access
class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _currentUser;
  UserLocation? _currentUserLocation;
  List<Review> _userReviews = [];
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  UserLocation? get currentUserLocation => _currentUserLocation;
  List<Review> get userReviews => _userReviews;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setAuthenticatedUser(Map<String, dynamic> userData) {
    _currentUser = User.fromJson(userData);
    _error = null;
  }

  /// Get display address from user location
  String get displayAddress {
    if (_currentUserLocation != null &&
        _currentUserLocation!.address.isNotEmpty) {
      // Truncate long addresses for display
      final address = _currentUserLocation!.address;
      if (address.length > 50) {
        return '${address.substring(0, 47)}...';
      }
      return address;
    }
    return 'Add your address';
  }

  /// Initialize provider and check if user is already logged in
  Future<void> initialize() async {
    await _apiService.initialize();
    if (_apiService.isAuthenticated) {
      await fetchProfile();
      await fetchUserLocation();
      await fetchUserReviews();
    }
  }

  /// Register new customer
  /// API: POST /api/accounts/register/
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: 'customer',
      );

      _isLoading = false;

      if (result['success']) {
        notifyListeners();
        return {
          'success': true,
          'message': result['data']['message'] ?? 'Signup successful',
        };
      } else {
        _error = result['data']['error'] ?? 'Registration failed';
        notifyListeners();
        return {'success': false, 'message': _error};
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Registration error: $e';
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  /// Start OTP for customer registration.
  Future<Map<String, dynamic>> requestRegisterOtp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.startAuthOtp(
        action: 'register',
        role: 'customer',
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      _isLoading = false;
      if (result['success']) {
        notifyListeners();
        return {
          'success': true,
          'sessionId': result['data']?['data']?['session_id'],
          'phone': result['data']?['data']?['phone'],
          'message': result['data']?['message'] ?? 'OTP sent successfully',
          'otp': result['data']?['data']?['otp'],
          'smsStatus': result['data']?['data']?['sms_status'],
        };
      }

      _error =
          result['data']?['message'] ??
          result['data']?['error'] ??
          'Failed to send OTP';
      notifyListeners();
      return {'success': false, 'message': _error};
    } catch (e) {
      _isLoading = false;
      _error = 'OTP request error: $e';
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  /// Start OTP for customer login.
  Future<Map<String, dynamic>> requestLoginOtp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.startAuthOtp(
        action: 'login',
        role: 'customer',
        email: email,
        password: password,
      );

      _isLoading = false;
      if (result['success']) {
        notifyListeners();
        return {
          'success': true,
          'sessionId': result['data']?['data']?['session_id'],
          'message': result['data']?['message'] ?? 'OTP sent successfully',
          'otp': result['data']?['data']?['otp'],
          'smsStatus': result['data']?['data']?['sms_status'],
          'phone': result['data']?['data']?['phone'],
        };
      }

      _error =
          result['data']?['message'] ??
          result['data']?['error'] ??
          'Failed to send OTP';
      notifyListeners();
      return {'success': false, 'message': _error};
    } catch (e) {
      _isLoading = false;
      _error = 'OTP request error: $e';
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  /// Verify OTP and complete auth for customer flows.
  Future<Map<String, dynamic>> verifyAuthOtp({
    required String sessionId,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.verifyAuthOtp(
        sessionId: sessionId,
        otp: otp,
      );

      _isLoading = false;
      if (result['success']) {
        final userData = result['data']?['data'] as Map<String, dynamic>?;
        final role = (userData?['role'] ?? '').toString().toLowerCase();

        if (userData == null || (role != 'customer' && role != 'user')) {
          _error = 'Invalid login. Please use worker login for workers.';
          notifyListeners();
          return {'success': false, 'message': _error};
        }

        _setAuthenticatedUser(userData);
        await fetchUserLocation();
        await fetchUserReviews();
        notifyListeners();

        return {
          'success': true,
          'message': result['data']?['message'] ?? 'OTP verified successfully',
        };
      }

      _error =
          result['data']?['message'] ??
          result['data']?['error'] ??
          'OTP verification failed';
      notifyListeners();
      return {'success': false, 'message': _error};
    } catch (e) {
      _isLoading = false;
      _error = 'OTP verification error: $e';
      notifyListeners();
      return {'success': false, 'message': _error};
    }
  }

  /// Resend OTP for an active auth challenge.
  Future<Map<String, dynamic>> resendAuthOtp(String sessionId) async {
    try {
      final result = await _apiService.resendAuthOtp(sessionId: sessionId);
      if (result['success']) {
        return {
          'success': true,
          'message': result['data']?['message'] ?? 'OTP resent successfully',
        };
      }

      return {
        'success': false,
        'message':
            result['data']?['message'] ??
            result['data']?['error'] ??
            'Failed to resend OTP',
      };
    } catch (e) {
      return {'success': false, 'message': 'OTP resend error: $e'};
    }
  }

  /// Login customer
  /// API: POST /api/accounts/login/
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email: email, password: password);

      _isLoading = false;

      if (result['success']) {
        final role = (result['data']['data']?['role'] ?? '')
            .toString()
            .toLowerCase();

        // Ensure this is a customer account
        if (role == 'worker') {
          _error =
              'Invalid login. Please use worker login for service providers.';
          notifyListeners();
          return false;
        }

        final userData = result['data']['data'] ?? {};
        _currentUser = User.fromJson(userData);
        await fetchUserLocation();
        await fetchUserReviews();
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error =
            result['data']['message'] ??
            result['data']['error'] ??
            'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Login error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Fetch current user profile
  /// API: POST /api/accounts/me/
  Future<void> fetchProfile() async {
    try {
      final result = await _apiService.getProfile();

      if (result['success']) {
        final userData = result['data'];
        final role = (userData['role'] ?? '').toString().toLowerCase();

        // Verify role is USER
        if (role == 'customer' || role == 'user') {
          _currentUser = User.fromJson(userData);
          _error = null;
        } else {
          _error = 'Invalid user role';
          await logout();
        }
      } else {
        _error = result['data']['error'] ?? 'Failed to fetch profile';
        await logout();
      }

      notifyListeners();
    } catch (e) {
      _error = 'Profile fetch error: $e';
      notifyListeners();
    }
  }

  /// Fetch user's location
  /// API: GET /api/locations/user/{userId}/
  Future<void> fetchUserLocation() async {
    if (_currentUser == null) return;

    try {
      final result = await _apiService.getUserLocation(_currentUser!.id);

      if (result['success'] && result['data'] != null) {
        _currentUserLocation = UserLocation.fromJson(result['data']);
        _error = null;
      } else {
        // User doesn't have a location yet, this is normal
        _currentUserLocation = null;
      }

      notifyListeners();
    } catch (e) {
      // Location not found is not an error, user just hasn't added location yet
      _currentUserLocation = null;
      notifyListeners();
    }
  }

  /// Update or create user location
  /// API: POST /api/locations/ or PUT /api/locations/{id}/
  Future<bool> updateUserLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final locationData = {
        'user_id': _currentUser!.id,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };

      final result = _currentUserLocation == null
          ? await _apiService.createUserLocation(locationData)
          : await _apiService.updateUserLocation(
              _currentUserLocation!.id,
              locationData,
            );

      _isLoading = false;

      if (result['success']) {
        _currentUserLocation = UserLocation.fromJson(result['data']);
        _error = null;
        notifyListeners();
        return true;
      } else {
        final data = result['data'];
        _error = data is Map<String, dynamic>
            ? (data['message'] ?? data['error'] ?? 'Failed to update location')
                  .toString()
            : 'Failed to update location';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Location update error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Fetch user's reviews
  /// API: GET /api/reviews/user/{userId}/
  Future<void> fetchUserReviews() async {
    if (_currentUser == null) return;

    try {
      final result = await _apiService.getUserReviews(_currentUser!.id);

      if (result['success']) {
        final reviewsData = result['data'] as List;
        _userReviews = reviewsData
            .map((json) => Review.fromJson(json))
            .toList();
        _error = null;
      } else {
        _userReviews = [];
      }

      notifyListeners();
    } catch (e) {
      _userReviews = [];
      notifyListeners();
    }
  }

  /// Update user profile
  /// API: PUT /api/accounts/profile/
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.updateProfile(
        userId: _currentUser!.id,
        name: name,
        email: email,
        phone: phone,
      );

      _isLoading = false;

      if (result['success']) {
        _currentUser = User.fromJson(result['data']);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['data']['error'] ?? 'Failed to update profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Profile update error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete user account
  /// API: DELETE /api/accounts/{userId}/
  Future<bool> deleteAccount(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.deleteAccount(userId);

      _isLoading = false;

      if (result['success']) {
        // Clear all user data
        _currentUser = null;
        _currentUserLocation = null;
        _userReviews = [];
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['data']['error'] ?? 'Failed to delete account';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Account deletion error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _apiService.logout();
    _currentUser = null;
    _currentUserLocation = null;
    _userReviews = [];
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
