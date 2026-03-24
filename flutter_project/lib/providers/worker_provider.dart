import 'package:flutter/material.dart';
import '../customer/models/user.dart';
import '../customer/models/worker.dart';
import 'package:flutter_project/customer/services/api_service.dart';

/// WorkerProvider - Manages worker (WORKER role) authentication and state
/// Communicates ONLY via REST API, no direct database access
class WorkerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _currentUser; // Base user data
  Worker? _workerProfile; // Worker-specific data
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  Worker? get workerProfile => _workerProfile;
  Worker? get currentWorker => _workerProfile; // Alias for workerProfile
  bool get isLoggedIn => _currentUser != null && _workerProfile != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Job statistics (dummy values for now)
  int get todayJobsCount => 5; // TODO: Implement actual count
  int get weekJobsCount => 25; // TODO: Implement actual count
  double get totalEarnings => 1250.50; // TODO: Implement actual earnings
  double get averageRating => 4.7; // TODO: Implement actual rating

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
    required String role,
    required String serviceType,
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
        role: role,
        serviceType: serviceType,
      );

      print("STATUS: ${result['statusCode']}");
      print("BODY: ${result['data']}");

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

  /// Verify OTP for worker registration
  /// API: POST /api/accounts/verify-otp/
  Future<Map<String, dynamic>> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.verifyOTP(
        phone: phone,
        otp: otp,
      );

      if (response['success']) {
        final data = response['data'];

        // if (data['user_id'] != null) {
        //   _currentUser = User.fromJson(data);
        // }

        _error = null;
        return data;
      } else {
        final error = response['data'];
        String message = "OTP verification failed";

        if (error is Map) {
          message = error.values.first.toString();
        }

        _error = message;
        throw Exception(message);
      }

    } catch (e) {
      _error = e.toString();
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login worker
  /// API: POST /api/accounts/login/
  Future<bool> login({
    required String identifier,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.login(identifier: identifier, password: password, role: role);

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

  /// Fetch current worker profile
  /// API: POST /api/accounts/me/
  Future<void> fetchProfile() async {
    try {
      final result = await _apiService.getProfile();

      if (result['success']) {
        final userData = result['data'];

        // Verify role is WORKER
        if (userData['role'] == 'WORKER') {
          _currentUser = User.fromJson(userData);

          // TODO: When backend provides worker details, parse them here
          // For now, create a basic worker profile
          _workerProfile = Worker(
            id: userData['id'] ?? 0,
            userId: userData['id'] ?? 0,
            isVerified: false,
            isAvailable: true,
          );

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
      return;
    }
  }

  /// Logout current worker
  Future<void> logout() async {
    await _apiService.logout();
    _currentUser = null;
    _workerProfile = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Update worker profile
  Future<bool> updateWorker(Map<String, dynamic> workerData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to update worker
      // For now, just update local data
      if (_workerProfile != null) {
        // Update worker profile with new data
        _workerProfile = Worker(
          id: _workerProfile!.id,
          userId: _workerProfile!.userId,
          isVerified: workerData['isVerified'] ?? _workerProfile!.isVerified,
          isAvailable: workerData['isAvailable'] ?? _workerProfile!.isAvailable,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Update error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement API call to update user
      // For now, just update local data
      if (_currentUser != null) {
        // Update user profile with new data
        _currentUser = User(
          id: _currentUser!.id,
          name: userData['name'] ?? _currentUser!.name,
          email: userData['email'] ?? _currentUser!.email,
          phone: userData['phone'] ?? _currentUser!.phone,
          passwordHash: _currentUser!.passwordHash, // Keep existing
          role: _currentUser!.role, // Keep existing
          createdAt: _currentUser!.createdAt,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Update error: $e';
      notifyListeners();
      return false;
    }
  }
}
