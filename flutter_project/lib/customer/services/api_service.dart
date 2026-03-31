import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API Service for backend communication
/// Handles all HTTP requests to Django backend
class ApiService {
  // Override with: --dart-define=API_BASE_URL=https://<host>/api
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Use environment-provided URL or fallback to production backend.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    // Default to Render production API URL.
    return 'https://servigopro.onrender.com/api';
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

      final response = await http
          .post(
            Uri.parse('$baseUrl/accounts/register/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

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

      final response = await http
          .post(
            Uri.parse('$baseUrl/accounts/auth/otp/start/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/accounts/auth/otp/verify/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'session_id': sessionId, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/accounts/auth/otp/resend/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'session_id': sessionId}),
          )
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/accounts/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .post(Uri.parse('$baseUrl/accounts/me/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

      final response = await http
          .put(
            Uri.parse('$baseUrl/accounts/profile/$userId/'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .delete(Uri.parse('$baseUrl/accounts/$userId/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .get(Uri.parse('$baseUrl/locations/user/$userId/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final payload = jsonDecode(response.body);
        final data =
            payload is Map<String, dynamic> &&
                payload['data'] is Map<String, dynamic>
            ? payload['data'] as Map<String, dynamic>
            : payload as Map<String, dynamic>;
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
      final response = await http
          .post(
            Uri.parse('$baseUrl/locations/'),
            headers: _headers,
            body: jsonEncode(locationData),
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : payload as Map<String, dynamic>;

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
      final response = await http
          .put(
            Uri.parse('$baseUrl/locations/$locationId/'),
            headers: _headers,
            body: jsonEncode(locationData),
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : payload as Map<String, dynamic>;

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
      final response = await http
          .get(Uri.parse('$baseUrl/reviews/user/$userId/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .get(Uri.parse('$baseUrl/services/categories/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
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
    int? categoryId,
    String? search,
    double? minRating,
    double? lat,
    double? lng,
    double? radiusKm,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/services/workers/').replace(
        queryParameters: {
          if (serviceId != null) 'service_id': serviceId.toString(),
          if (categoryId != null) 'category_id': categoryId.toString(),
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (minRating != null) 'min_rating': minRating.toString(),
          if (lat != null) 'lat': lat.toString(),
          if (lng != null) 'lng': lng.toString(),
          if (radiusKm != null) 'radius_km': radiusKm.toString(),
        },
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
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
      final response = await http
          .get(
            Uri.parse('$baseUrl/services/workers/$workerId/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .get(Uri.parse('$baseUrl/bookings/user/$userId/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .post(
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
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic>
          ? (payload['data'] is Map<String, dynamic>
                ? payload['data'] as Map<String, dynamic>
                : payload)
          : <String, dynamic>{};

      return {
        'success': response.statusCode == 201,
        'statusCode': response.statusCode,
        'message': payload is Map<String, dynamic>
            ? payload['message']?.toString()
            : null,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network error',
        'data': <String, dynamic>{},
      };
    }
  }

  /// Update booking status
  /// PATCH /api/bookings/{bookingId}/status/
  Future<Map<String, dynamic>> updateBookingStatus(
    int bookingId,
    String status,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/bookings/$bookingId/status/'),
            headers: _headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 15));

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

  /// Worker reschedules booking with new datetime and reason
  /// POST /api/bookings/{bookingId}/reschedule/
  Future<Map<String, dynamic>> rescheduleBooking({
    required int bookingId,
    required DateTime scheduledDate,
    required String reason,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$bookingId/reschedule/'),
            headers: _headers,
            body: jsonEncode({
              'scheduled_date': scheduledDate.toIso8601String(),
              'reason': reason,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic>
          ? (payload['data'] is Map<String, dynamic>
                ? payload['data'] as Map<String, dynamic>
                : payload)
          : <String, dynamic>{};
      final message = payload is Map<String, dynamic>
          ? payload['message']?.toString()
          : null;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': message,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network error',
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Get booking by id
  /// GET /api/bookings/{bookingId}/
  Future<Map<String, dynamic>> getBookingById(int bookingId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/bookings/$bookingId/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

  /// Get worker availability for a specific date
  /// GET /api/bookings/availability/?worker_id=&date=YYYY-MM-DD
  Future<Map<String, dynamic>> getWorkerAvailability({
    required int workerId,
    required DateTime date,
  }) async {
    try {
      final dateString = date.toIso8601String().split('T').first;
      final uri = Uri.parse('$baseUrl/bookings/availability/').replace(
        queryParameters: {'worker_id': workerId.toString(), 'date': dateString},
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
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
      final response = await http
          .get(
            Uri.parse('$baseUrl/reviews/worker/$workerId/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/reviews/create/'),
            headers: _headers,
            body: jsonEncode({
              'booking_id': bookingId,
              'user_id': userId,
              'worker_id': workerId,
              'rating': rating,
              'comment': comment ?? '',
            }),
          )
          .timeout(const Duration(seconds: 15));

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

  /// Check if review exists for a booking
  /// GET /api/reviews/check/<booking_id>/?user_id=<user_id>
  Future<Map<String, dynamic>> checkReviewStatus({
    required int bookingId,
    required int userId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/reviews/check/$bookingId/?user_id=$userId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

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

  /// Get worker list
  /// GET /api/accounts/workers/
  Future<Map<String, dynamic>> getWorkers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/accounts/workers/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

  /// Upload worker profile photo
  /// POST /api/workers/profile-photo/
  Future<Map<String, dynamic>> uploadWorkerProfilePhoto({
    required String imagePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/workers/profile-photo/'),
      );

      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }

      request.files.add(
        await http.MultipartFile.fromPath('profile_photo', imagePath),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final payload = jsonDecode(response.body);

      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data']
          : payload;

      final message = payload is Map<String, dynamic>
          ? payload['message']?.toString()
          : null;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': message,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network error',
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Get selectable service list for current worker
  /// GET /api/workers/services/
  Future<Map<String, dynamic>> getWorkerServicesSelection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/workers/services/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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
        'message': payload is Map<String, dynamic> ? payload['message'] : null,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': <String, dynamic>{},
        'message': 'Network error: $e',
      };
    }
  }

  /// Update selected services for current worker
  /// POST /api/workers/services/
  Future<Map<String, dynamic>> updateWorkerServicesSelection(
    List<int> serviceIds,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/workers/services/'),
            headers: _headers,
            body: jsonEncode({'service_ids': serviceIds}),
          )
          .timeout(const Duration(seconds: 15));

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
        'message': payload is Map<String, dynamic>
            ? (payload['message']?.toString() ?? '')
            : '',
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': <String, dynamic>{},
        'message': 'Network error: $e',
      };
    }
  }

  /// Start worker KYC session
  /// POST /api/workers/kyc/start/
  Future<Map<String, dynamic>> startWorkerKycSession() async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/workers/kyc/start/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic> data;
      try {
        final payload = jsonDecode(response.body);
        data = payload is Map<String, dynamic> ? payload : <String, dynamic>{};
      } catch (_) {
        final preview = response.body.length > 180
            ? '${response.body.substring(0, 180)}...'
            : response.body;
        data = {
          'success': false,
          'message': 'Server returned non-JSON response',
          'raw': preview,
        };
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

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

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

  /// Get worker statistics
  /// GET /api/workers/stats/
  Future<Map<String, dynamic>> getWorkerStats() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/workers/stats/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

  /// Get worker earnings summary (month-wise graph + deductions)
  /// GET /api/workers/earnings-summary/?months=6
  Future<Map<String, dynamic>> getWorkerEarningsSummary({
    int months = 6,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/workers/earnings-summary/',
      ).replace(queryParameters: {'months': months.toString()});

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
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

  /// Get worker completed jobs history for Past Services
  /// GET /api/workers/past-services/?limit=50
  Future<Map<String, dynamic>> getWorkerPastServices({int limit = 50}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/workers/past-services/',
      ).replace(queryParameters: {'limit': limit.toString()});

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
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

  /// Get worker bank details
  /// GET /api/workers/bank-details/
  Future<Map<String, dynamic>> getWorkerBankDetails() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/workers/bank-details/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

  /// Save worker bank details
  /// POST /api/workers/bank-details/
  Future<Map<String, dynamic>> saveWorkerBankDetails({
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    String? upiId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/workers/bank-details/'),
            headers: _headers,
            body: jsonEncode({
              'account_holder_name': accountHolderName,
              'bank_name': bankName,
              'account_number': accountNumber,
              'ifsc_code': ifscCode,
              'upi_id': upiId ?? '',
            }),
          )
          .timeout(const Duration(seconds: 15));

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

  /// Submit worker UPI QR image and extract UPI ID on backend
  /// POST /api/workers/submit-upi-qr/
  Future<Map<String, dynamic>> submitWorkerUpiQr({
    required String imagePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/workers/submit-upi-qr/'),
      );

      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }

      request.files.add(
        await http.MultipartFile.fromPath('qr_image', imagePath),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final payload = jsonDecode(response.body);

      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data']
          : payload;

      final message = payload is Map<String, dynamic>
          ? payload['message']?.toString()
          : null;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': message,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network error',
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Get wallet balance for a user
  /// GET /api/wallet/balance/{userId}/
  Future<Map<String, dynamic>> getUserWalletBalance(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/wallet/balance/$userId/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

  /// Get wallet transactions for a user
  /// GET /api/wallet/transactions/{userId}/
  Future<Map<String, dynamic>> getUserWalletTransactions(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/wallet/transactions/$userId/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

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

  /// Add money to wallet
  /// POST /api/wallet/add/
  Future<Map<String, dynamic>> addMoneyToWallet({
    required int userId,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/wallet/add/'),
            headers: _headers,
            body: jsonEncode({
              'userId': userId,
              'amount': amount,
              'description': description,
            }),
          )
          .timeout(const Duration(seconds: 15));

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

  /// Deduct money from wallet
  /// POST /api/wallet/deduct/
  Future<Map<String, dynamic>> deductMoneyFromWallet({
    required int userId,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/wallet/deduct/'),
            headers: _headers,
            body: jsonEncode({
              'userId': userId,
              'amount': amount,
              'description': description,
            }),
          )
          .timeout(const Duration(seconds: 15));

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

  /// Process wallet refund
  /// POST /api/wallet/refund/
  Future<Map<String, dynamic>> processWalletRefund({
    required int userId,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/wallet/refund/'),
            headers: _headers,
            body: jsonEncode({
              'userId': userId,
              'amount': amount,
              'description': description,
            }),
          )
          .timeout(const Duration(seconds: 15));

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

  /// Get payment QR payload for a booking
  /// GET /api/wallet/qr/{bookingId}/
  Future<Map<String, dynamic>> getPaymentQr(int bookingId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/wallet/qr/$bookingId/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Generate payment QR payload with image + UPI link
  /// POST /api/wallet/qr/generate/
  Future<Map<String, dynamic>> generatePaymentQr({
    required int bookingId,
    required double amount,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/wallet/qr/generate/'),
            headers: _headers,
            body: jsonEncode({
              'booking_id': bookingId,
              'amount': amount,
              'use_admin_upi': true,
            }),
          )
          .timeout(const Duration(seconds: 15));

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
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Confirm payment and complete booking
  /// POST /api/wallet/confirm/
  Future<Map<String, dynamic>> confirmPayment({
    required int bookingId,
    required String paymentMethod,
    String? transactionRef,
    String? paymentStatus,
    bool useWallet = false,
    int? userId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/wallet/confirm/'),
            headers: _headers,
            body: jsonEncode({
              'booking_id': bookingId,
              'payment_method': paymentMethod,
              if (transactionRef != null && transactionRef.isNotEmpty)
                'transaction_ref': transactionRef,
              if (paymentStatus != null && paymentStatus.isNotEmpty)
                'payment_status': paymentStatus,
              'use_wallet': useWallet,
              if (userId != null) 'user_id': userId,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data'] as Map<String, dynamic>
          : payload as Map<String, dynamic>;

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

  /// Get worker notifications
  /// GET /api/workers/notifications/
  Future<Map<String, dynamic>> getWorkerNotifications() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/workers/notifications/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

  /// Mark all worker notifications as read
  /// POST /api/workers/notifications/mark-all-read/
  Future<Map<String, dynamic>> markAllWorkerNotificationsRead() async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/workers/notifications/mark-all-read/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

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

  /// Initiate job OTP - generate and send OTP to customer
  /// POST /api/bookings/{booking_id}/initiate-otp/
  Future<Map<String, dynamic>> initiateJobOTP({required int bookingId}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$bookingId/initiate-otp/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data']
          : payload;
      final message = payload is Map<String, dynamic>
          ? payload['message']?.toString()
          : null;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': message,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network error',
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Verify job OTP and activate job
  /// POST /api/bookings/{booking_id}/verify-otp/
  Future<Map<String, dynamic>> verifyJobOTP({
    required int bookingId,
    required String otp,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$bookingId/verify-otp/'),
            headers: _headers,
            body: jsonEncode({'otp': otp}),
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data =
          payload is Map<String, dynamic> &&
              payload['data'] is Map<String, dynamic>
          ? payload['data']
          : payload;
      final message = payload is Map<String, dynamic>
          ? payload['message']?.toString()
          : null;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': message,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network error',
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Worker marks in-progress job as done and moves it to awaiting_payment
  /// POST /api/bookings/{booking_id}/mark-done/
  Future<Map<String, dynamic>> markJobDone({required int bookingId}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$bookingId/mark-done/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic>
          ? payload['data'] ?? payload
          : payload;
      final message = payload is Map<String, dynamic>
          ? payload['message']?.toString()
          : null;
      final code = payload is Map<String, dynamic>
          ? payload['code']?.toString()
          : null;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': message,
        'code': code,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network error',
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Customer confirms job completion in demo flow (no QR/payment gateway)
  /// POST /api/bookings/{booking_id}/confirm-complete/
  Future<Map<String, dynamic>> confirmBookingCompletion({
    required int bookingId,
    int? userId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/bookings/$bookingId/confirm-complete/'),
            headers: _headers,
            body: jsonEncode({if (userId != null) 'user_id': userId}),
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic>
          ? payload['data'] ?? payload
          : payload;
      final message = payload is Map<String, dynamic>
          ? payload['message']?.toString()
          : null;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': message,
        'data': data,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network error',
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Save/update account FCM token
  /// POST /api/accounts/fcm-token/
  Future<Map<String, dynamic>> saveFcmToken(String fcmToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/accounts/fcm-token/'),
            headers: _headers,
            body: jsonEncode({'fcm_token': fcmToken}),
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': payload,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Get worker weekly availability schedule
  /// GET /api/workers/availability/
  Future<Map<String, dynamic>> getWorkerAvailabilitySchedule() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/workers/availability/'), headers: _headers)
          .timeout(const Duration(seconds: 15));

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

  /// Save worker weekly availability schedule
  /// POST /api/workers/availability/
  Future<Map<String, dynamic>> saveWorkerAvailabilitySchedule(
    List<Map<String, dynamic>> availability,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/workers/availability/'),
            headers: _headers,
            body: jsonEncode({'availability': availability}),
          )
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': payload,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': {'error': 'Network error: $e'},
      };
    }
  }

  /// Validate IFSC via backend endpoint
  /// GET /api/workers/validate-ifsc/?ifsc=SBIN0001234
  Future<Map<String, dynamic>> validateIfsc(String ifsc) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/workers/validate-ifsc/',
      ).replace(queryParameters: {'ifsc': ifsc});
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      final payload = jsonDecode(response.body);
      final data = payload is Map<String, dynamic>
          ? (payload['data'] ?? payload)
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
