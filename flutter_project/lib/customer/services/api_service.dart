import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API Service for backend communication
/// Handles all HTTP requests to Django backend
class ApiService {
  // Base URL for API - Update this with your backend IP
  static const String baseUrl = 'http://192.168.1.100:8000/api';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Store tokens
  String? _accessToken;
  String? _refreshToken;

  /// Initialize and load tokens from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  /// Save tokens to storage
  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  /// Clear tokens from storage
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  /// Get authorization headers
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// User/Worker Signup
  /// POST /api/accounts/signup/
  Future<Map<String, dynamic>> signup({
    required String username,
    required String password,
    required String role, // 'USER' or 'WORKER'
    String? serviceType, // Required if role = 'WORKER'
  }) async {
    try {
      final body = {
        'username': username,
        'password': password,
        'role': role,
      };
      
      if (role == 'WORKER' && serviceType != null) {
        body['service_type'] = serviceType;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/accounts/signup/'),
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

  /// User/Worker Login
  /// POST /api/accounts/login/
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Save tokens
        await _saveTokens(data['access'], data['refresh']);
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
  Future<Map<String, dynamic>> createUserLocation(Map<String, dynamic> locationData) async {
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
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': data is List ? data : [],
        };
      }

      final data = jsonDecode(response.body);
      return {
        'success': false,
        'statusCode': response.statusCode,
        'data': [],
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'data': [],
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