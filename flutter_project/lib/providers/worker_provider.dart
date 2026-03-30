import 'package:flutter/material.dart';
import '../customer/models/user.dart';
import '../customer/models/worker.dart';
import '../customer/models/user_location.dart';
import 'package:flutter_project/customer/services/api_service.dart';

/// WorkerProvider - Manages worker (WORKER role) authentication and state
/// Communicates ONLY via REST API, no direct database access
class WorkerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _currentUser; // Base user data
  Worker? _workerProfile; // Worker-specific data
  UserLocation? _currentUserLocation;
  bool _isLoading = false;
  String? _error;

  // Worker statistics
  int _todayJobsCount = 0;
  final int _weekJobsCount = 0;
  double _totalEarnings = 0;
  double _averageRating = 0;
  int _completedJobs = 0;

  User? get currentUser => _currentUser;
  Worker? get currentWorker => _workerProfile;
  Worker? get workerProfile => _workerProfile;
  UserLocation? get currentUserLocation => _currentUserLocation;
  bool get isLoggedIn => _currentUser != null && _workerProfile != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stats getters with real data
  int get todayJobsCount => _todayJobsCount;
  int get weekJobsCount => _weekJobsCount;
  double get totalEarnings => _totalEarnings;
  double get averageRating => _averageRating;
  int get completedJobs => _completedJobs;

  void _setAuthenticatedWorker(Map<String, dynamic> userData) {
    _currentUser = User.fromJson(userData);
    _workerProfile = Worker(
      id: userData['id'] ?? 0,
      userId: userData['id'] ?? 0,
      isVerified: false,
      isAvailable: true,
    );
    _error = null;
  }

  /// Initialize provider and check if worker is already logged in
  Future<void> initialize() async {
    await _apiService.initialize();
    if (_apiService.isAuthenticated) {
      await fetchProfile();
    }
  }

  /// Register new worker
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
        role: 'worker',
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

  /// Start OTP for worker registration.
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
        role: 'worker',
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

  /// Start OTP for worker login.
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
        role: 'worker',
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

  /// Verify OTP and complete auth for worker flows.
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

        if (userData == null || role != 'worker') {
          _error = 'Invalid login. Please use customer login.';
          notifyListeners();
          return {'success': false, 'message': _error};
        }

        _setAuthenticatedWorker(userData);
        await fetchProfile();
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

  /// Login worker
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

        // Ensure this is a worker account
        if (role != 'worker') {
          _error = 'Invalid login. Please use customer login.';
          notifyListeners();
          return false;
        }

        final userData = result['data']['data'] ?? {};
        _currentUser = User.fromJson(userData);
        _workerProfile = Worker(
          id: userData['id'] ?? 0,
          userId: userData['id'] ?? 0,
          isVerified: false,
          isAvailable: true,
        );
        _error = null;
        await fetchProfile();
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

  /// Fetch current worker profile with stats
  /// API: GET /api/accounts/me/ and GET /api/workers/profile/ and GET /api/workers/stats/
  Future<void> fetchProfile() async {
    try {
      final result = await _apiService.getProfile();

      if (result['success']) {
        final userData = result['data'];
        final role = (userData['role'] ?? '').toString().toLowerCase();

        // Verify role is WORKER
        if (role == 'worker') {
          _currentUser = User.fromJson(userData);

          // Fetch detailed worker profile
          await fetchWorkerProfile();

          // Fetch worker statistics
          await fetchWorkerStats();

          // Fetch worker location from user_locations table
          await fetchUserLocation();

          _error = null;
        } else {
          _error = 'Invalid worker role';
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

  /// Fetch detailed worker profile from workers app
  Future<void> fetchWorkerProfile() async {
    try {
      final result = await _apiService.getWorkerProfile();

      if (result['success']) {
        final data = result['data'];
        _workerProfile = Worker(
          id: data['worker_id'] ?? 0,
          userId: data['user_id'] ?? 0,
          isVerified: data['is_verified'] ?? false,
          isAvailable: data['is_available'] ?? true,
        );
      } else {
        // Fallback: create basic profile
        _workerProfile = Worker(
          id: _currentUser?.id ?? 0,
          userId: _currentUser?.id ?? 0,
          isVerified: false,
          isAvailable: true,
        );
      }
    } catch (e) {
      // Fallback: create basic profile
      _workerProfile = Worker(
        id: _currentUser?.id ?? 0,
        userId: _currentUser?.id ?? 0,
        isVerified: false,
        isAvailable: true,
      );
    }
  }

  /// Fetch worker statistics from API
  Future<void> fetchWorkerStats() async {
    try {
      final result = await _apiService.getWorkerStats();

      if (result['success']) {
        final data = result['data'];
        _todayJobsCount = data['today_jobs_count'] ?? 0;
        _totalEarnings = (data['total_earnings'] ?? 0).toDouble();
        _averageRating = (data['average_rating'] ?? 0).toDouble();
        _completedJobs = data['completed_jobs'] ?? 0;
      }
    } catch (e) {
      // Use default values if fetch fails
    }
  }

  /// Update logged-in worker user profile in backend.
  Future<bool> updateUser(Map<String, dynamic> userData) async {
    if (_currentUser == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.updateProfile(
        userId: _currentUser!.id,
        name: userData['name']?.toString(),
        email: userData['email']?.toString(),
        phone: userData['phone']?.toString(),
      );

      _isLoading = false;

      if (result['success']) {
        final updated = result['data'] as Map<String, dynamic>;
        _currentUser = User.fromJson(updated);
        _error = null;
        notifyListeners();
        return true;
      }

      final failureData = result['data'];
      _error = failureData is Map<String, dynamic>
          ? (failureData['message'] ??
                    failureData['error'] ??
                    'Failed to update profile')
                .toString()
          : 'Failed to update profile';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Profile update error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Fetch worker user's location from backend.
  Future<void> fetchUserLocation() async {
    if (_currentUser == null) return;

    try {
      final result = await _apiService.getUserLocation(_currentUser!.id);

      if (result['success'] && result['data'] != null) {
        _currentUserLocation = UserLocation.fromJson(result['data']);
        _error = null;
      } else {
        _currentUserLocation = null;
      }

      notifyListeners();
    } catch (_) {
      _currentUserLocation = null;
      notifyListeners();
    }
  }

  /// Create or update worker user's location in backend.
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
      }

      final failureData = result['data'];
      _error = failureData is Map<String, dynamic>
          ? (failureData['message'] ??
                    failureData['error'] ??
                    'Failed to update location')
                .toString()
          : 'Failed to update location';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Location update error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Fetch workers list from backend users table.
  Future<List<User>> fetchWorkers() async {
    try {
      final result = await _apiService.getWorkers();
      if (!result['success']) {
        return <User>[];
      }

      final list = result['data'] as List<dynamic>;
      return list.whereType<Map<String, dynamic>>().map(User.fromJson).toList();
    } catch (_) {
      return <User>[];
    }
  }

  /// Logout current worker
  Future<void> logout() async {
    await _apiService.logout();
    _currentUser = null;
    _workerProfile = null;
    _currentUserLocation = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
