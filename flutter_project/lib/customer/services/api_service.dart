import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API Service for backend communication
/// Handles all HTTP requests to Django backend
class ApiService {
  // Override with: --dart-define=API_BASE_URL=http://<host>:8000/api
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Use emulator-friendly defaults when API_BASE_URL is not provided.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Store tokens
  String? _accessToken;

  /// Initialize and load tokens from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  /// Save tokens to storage
  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  /// Save a lightweight local token using user id.
  Future<void> setAccessTokenFromUserId(int userId) async {
    await _saveTokens(userId.toString(), '');
  }

  /// Clear tokens from storage
  Future<void> clearTokens() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  /// Get authorization headers
  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// User/Worker Register
  /// POST /api/accounts/register/
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role, // e.g. customer/worker
  }) async {
    try {
      final body = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/accounts/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Start OTP challenge for user/worker register or login
  /// POST /api/accounts/auth/otp/start/
  Future<Map<String, dynamic>> startAuthOtp({
    required String action,
    required String role,
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{
        'action': action,
        'role': role,
        'email': email,
        'password': password,
      };

      if (name != null && name.isNotEmpty) {
        body['name'] = name;
      }
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/accounts/auth/otp/start/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Verify OTP challenge for user/worker register or login
  /// POST /api/accounts/auth/otp/verify/
  Future<Map<String, dynamic>> verifyAuthOtp({
    required String sessionId,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/auth/otp/verify/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId, 'otp': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userId = data['data']?['id'];
        if (userId != null) {
          await _saveTokens(userId.toString(), '');
        }
      }

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Resend OTP challenge
  /// POST /api/accounts/auth/otp/resend/
  Future<Map<String, dynamic>> resendAuthOtp({
    required String sessionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/auth/otp/resend/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId}),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// User/Worker Login
  /// POST /api/accounts/login/
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Backend doesn't issue JWT yet. Use user id as a lightweight local token
        // so profile endpoints can resolve the current user.
        final userId = data['data']?['id'];
        if (userId != null) {
          await _saveTokens(userId.toString(), '');
        } else {
          await _saveTokens('local_session', '');
        }
      }

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Get logged-in user profile
  /// POST /api/accounts/me/
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/me/'),
        headers: _headers,
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data']
          : payload;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Update user profile
  /// PUT /api/accounts/profile/{userId}/
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;

      final response = await http.put(
        Uri.parse('$baseUrl/accounts/profile/$userId/'),
        headers: _headers,
        body: jsonEncode(body),
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data']
          : payload;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Delete user account
  /// DELETE /api/accounts/{userId}/
  Future<Map<String, dynamic>> deleteAccount(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/accounts/$userId/'),
        headers: _headers,
      );

      // Clear tokens after successful deletion
      if (response.statusCode == 204 || response.statusCode == 200) {
        await clearTokens();
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': {'message': 'Account deleted successfully'},
        };
      }

      final data = jsonDecode(response.body);

      return {
        'success': false,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Get user location
  /// GET /api/locations/user/{userId}/
  Future<Map<String, dynamic>> getUserLocation(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/locations/user/$userId/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': data,
        };
      } else if (response.statusCode == 404) {
        // No location found is not an error
        return {
          'success': false,
          'statusCode': response.statusCode,
          'data': null,
        };
      }

      final data = jsonDecode(response.body);
      return {
        'success': false,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Create user location
  /// POST /api/locations/
  Future<Map<String, dynamic>> createUserLocation(
    Map<String, dynamic> locationData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/locations/'),
        headers: _headers,
        body: jsonEncode(locationData),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Update user location
  /// PUT /api/locations/{locationId}/
  Future<Map<String, dynamic>> updateUserLocation(
    int locationId,
    Map<String, dynamic> locationData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/locations/$locationId/'),
        headers: _headers,
        body: jsonEncode(locationData),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Get user reviews
  /// GET /api/reviews/user/{userId}/
  Future<Map<String, dynamic>> getUserReviews(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/user/$userId/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final payload = jsonDecode(response.body);
        final data = payload is Map<String, dynamic> && payload['data'] is List
            ? payload['data'] as List
            : <dynamic>[];
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': data,
        };
      }

      return {'success': false, 'statusCode': response.statusCode, 'data': []};
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': []};
    }
  }

  /// Get service categories
  /// GET /api/services/categories/
  Future<Map<String, dynamic>> getServiceCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/categories/'),
        headers: _headers,
      );

      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic> && payload['data'] is List
          ? payload['data'] as List
          : <dynamic>[];

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <dynamic>[]};
    }
  }

  /// Get service list
  /// GET /api/services/list/?category_id=
  Future<Map<String, dynamic>> getServices({int? categoryId}) async {
    try {
      final uri = Uri.parse('$baseUrl/services/list/').replace(
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers);
      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic> && payload['data'] is List
          ? payload['data'] as List
          : <dynamic>[];

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <dynamic>[]};
    }
  }

  /// Get workers for customer discovery
  /// GET /api/services/workers/?service_id=&search=&min_rating=
  Future<Map<String, dynamic>> getCustomerWorkers({
    int? serviceId,
    String? search,
    double? minRating,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services/workers/').replace(
        queryParameters: {
          if (serviceId != null) 'service_id': serviceId.toString(),
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (minRating != null) 'min_rating': minRating.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers);
      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic> && payload['data'] is List
          ? payload['data'] as List
          : <dynamic>[];

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <dynamic>[]};
    }
  }

  /// Get worker detail
  /// GET /api/services/workers/{workerId}/
  Future<Map<String, dynamic>> getWorkerDetails(int workerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/services/workers/$workerId/'),
        headers: _headers,
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <String, dynamic>{}};
    }
  }

  /// Get bookings for user
  /// GET /api/bookings/user/{userId}/
  Future<Map<String, dynamic>> getUserBookings(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/user/$userId/'),
        headers: _headers,
      );

      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic> && payload['data'] is List
          ? payload['data'] as List
          : <dynamic>[];

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <dynamic>[]};
    }
  }

  /// Create booking
  /// POST /api/bookings/create/
  Future<Map<String, dynamic>> createBooking({
    required int userId,
    required int workerId,
    required int serviceId,
    required DateTime scheduledDate,
    required double totalAmount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings/create/'),
        headers: _headers,
        body: jsonEncode({
          'user_id': userId,
          'worker_id': workerId,
          'service_id': serviceId,
          'scheduled_date': scheduledDate.toIso8601String(),
          'status': 'pending',
          'total_amount': totalAmount,
        }),
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      return {
        'success': response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <String, dynamic>{}};
    }
  }

  /// Update booking status
  /// PATCH /api/bookings/{bookingId}/status/
  Future<Map<String, dynamic>> updateBookingStatus(
    int bookingId,
    String status,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/status/'),
        headers: _headers,
        body: jsonEncode({'status': status}),
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <String, dynamic>{}};
    }
  }

  /// Get booking by id
  /// GET /api/bookings/{bookingId}/
  Future<Map<String, dynamic>> getBookingById(int bookingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bookings/$bookingId/'),
        headers: _headers,
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <String, dynamic>{}};
    }
  }

  /// Get reviews for worker
  /// GET /api/reviews/worker/{workerId}/
  Future<Map<String, dynamic>> getWorkerReviews(int workerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/worker/$workerId/'),
        headers: _headers,
      );

      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic> && payload['data'] is List
          ? payload['data'] as List
          : <dynamic>[];

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <dynamic>[]};
    }
  }

  /// Create review
  /// POST /api/reviews/create/
  Future<Map<String, dynamic>> createReview({
    required int bookingId,
    required int userId,
    required int workerId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews/create/'),
        headers: _headers,
        body: jsonEncode({
          'booking_id': bookingId,
          'user_id': userId,
          'worker_id': workerId,
          'rating': rating,
          'comment': comment ?? '',
        }),
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      return {
        'success': response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <String, dynamic>{}};
    }
  }

  /// Get worker list
  /// GET /api/accounts/workers/
  Future<Map<String, dynamic>> getWorkers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/accounts/workers/'),
        headers: _headers,
      );

      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic> && payload['data'] is List
          ? payload['data'] as List
          : <dynamic>[];

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'statusCode': 500, 'data': <dynamic>[]};
    }
  }

  /// Get worker profile
  /// GET /api/workers/profile/
  Future<Map<String, dynamic>> getWorkerProfile() async {
    try {
      final url = '$baseUrl/workers/profile/';
      print('🔵 DEBUG: Fetching worker profile from: $url');
      print('🔵 DEBUG: Headers: $_headers');

      final response = await http.get(Uri.parse(url), headers: _headers);

      print('🔵 DEBUG: Profile response status: ${response.statusCode}');
      print(
        '🔵 DEBUG: Profile response body (first 300 chars): ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}',
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data']
          : payload;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      print('❌ ERROR in getWorkerProfile: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Get worker jobs with filtering
  /// GET /api/workers/jobs/?filter=day|week|month&status=optional
  Future<Map<String, dynamic>> getWorkerJobs({
    String filter = 'day',
    String? status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/workers/jobs/').replace(
        queryParameters: {
          'filter': filter,
          if (status != null) 'status': status,
        },
      );

      print('🔵 DEBUG: Fetching jobs from: $uri');
      print('🔵 DEBUG: Headers: $_headers');
      print('🔵 DEBUG: Access token: ${_headers['Authorization']}');

      final response = await http.get(uri, headers: _headers);

      print('🔵 DEBUG: Response status: ${response.statusCode}');
      print(
        '🔵 DEBUG: Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data']
          : payload;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      print('❌ ERROR in getWorkerJobs: $e');
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Get worker statistics
  /// GET /api/workers/stats/
  Future<Map<String, dynamic>> getWorkerStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workers/stats/'),
        headers: _headers,
      );

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data']
          : payload;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Logout
  Future<void> logout() async {
    await clearTokens();
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _accessToken != null;

  /// Get current access token
  String? get accessToken => _accessToken;
}
