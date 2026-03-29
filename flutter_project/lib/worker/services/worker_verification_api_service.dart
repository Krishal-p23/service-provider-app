import 'package:dio/dio.dart' as dio_lib;

/// API service for worker document verification
/// Handles uploading documents and checking verification status
class WorkerVerificationApiService {
  final dio_lib.Dio _dio;

  // Base URL with environment override support
  // Override with: --dart-define=API_BASE_URL=http://<host>:8000/api
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    // Default to localhost for desktop/emulator
    return 'http://127.0.0.1:8000/api';
  }

  // Document type constants matching backend
  static const String DOC_TYPE_AADHAR = 'aadhar';
  static const String DOC_TYPE_PAN = 'pan';
  static const String DOC_TYPE_DRIVING_LICENSE = 'driving_license';
  static const String DOC_TYPE_PASSPORT = 'passport';
  static const String DOC_TYPE_VOTER_ID = 'voter_id';

  // Status constants
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_VERIFIED = 'verified';
  static const String STATUS_REJECTED = 'rejected';

  WorkerVerificationApiService({dio_lib.Dio? dio})
    : _dio = dio ?? dio_lib.Dio();

  /// Upload worker document for verification
  ///
  /// Parameters:
  /// - [token]: Authentication bearer token
  /// - [documentType]: Type of document (aadhar, pan, driving_license, passport, voter_id)
  /// - [documentNumber]: Document ID number
  /// - [imagePath]: Path to image file
  /// - [imageBackPath]: Optional path to back side image
  ///
  /// Returns: Map containing verification response data
  Future<Map<String, dynamic>> uploadDocument({
    required String token,
    required String documentType,
    required String documentNumber,
    required String imagePath,
    String? imageBackPath,
  }) async {
    try {
      final formData = dio_lib.FormData.fromMap({
        'document_type': documentType,
        'document_number': documentNumber,
        'document_image': await dio_lib.MultipartFile.fromFile(
          imagePath,
          filename: 'document_front.jpg',
        ),
      });

      // Add back side image if provided
      if (imageBackPath != null && imageBackPath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'document_image_back',
            await dio_lib.MultipartFile.fromFile(
              imageBackPath,
              filename: 'document_back.jpg',
            ),
          ),
        );
      }

      final response = await _dio.post(
        '$baseUrl/workers/documents/upload/',
        data: formData,
        options: dio_lib.Options(
          headers: {'Authorization': 'Bearer $token'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data['data'] ?? {},
          'message':
              response.data['message'] ?? 'Document uploaded successfully',
        };
      } else {
        return {
          'success': false,
          'error': response.data['error'] ?? 'Failed to upload document',
        };
      }
    } on dio_lib.DioException catch (e) {
      return {'success': false, 'error': _handleDioError(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  /// Get current document verification status for worker
  ///
  /// Parameters:
  /// - [token]: Authentication bearer token
  ///
  /// Returns: Map containing verification status
  Future<Map<String, dynamic>> getVerificationStatus({
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/workers/documents/upload/',
        options: dio_lib.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data == null) {
          // No documents submitted yet
          return {
            'success': true,
            'hasDocument': false,
            'message': 'No documents submitted yet',
          };
        }

        return {
          'success': true,
          'hasDocument': true,
          'documentType': data['document_type'] ?? '',
          'documentTypeDisplay': data['document_type_display'] ?? '',
          'documentNumber': data['document_number'] ?? '',
          'documentImage': data['document_image'] ?? '',
          'documentImageBack': data['document_image_back'],
          'status': data['status'] ?? STATUS_PENDING,
          'statusDisplay': data['status_display'] ?? '',
          'isVerified': data['is_verified'] ?? false,
          'isPending': data['is_pending'] ?? false,
          'isRejected': data['is_rejected'] ?? false,
          'rejectionReason': data['rejection_reason'] ?? '',
          'createdAt': data['created_at'] ?? '',
          'verifiedAt': data['verified_at'],
        };
      } else {
        return {
          'success': false,
          'error':
              response.data['error'] ?? 'Failed to fetch verification status',
        };
      }
    } on dio_lib.DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // No document found - this is OK
        return {
          'success': true,
          'hasDocument': false,
          'message': 'No documents submitted yet',
        };
      }
      return {'success': false, 'error': _handleDioError(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  /// Admin: Get list of pending documents for review
  ///
  /// Parameters:
  /// - [token]: Admin authentication bearer token
  /// - [status]: Filter by status (pending, verified, rejected) - optional
  ///
  /// Returns: List of documents waiting for review
  Future<Map<String, dynamic>> getAdminDocuments({
    required String token,
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        params['status'] = status;
      }

      final response = await _dio.get(
        '$baseUrl/workers/documents/admin/',
        queryParameters: params,
        options: dio_lib.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final documents = response.data['data'] ?? [];
        return {
          'success': true,
          'documents': documents,
          'count': documents.length,
        };
      } else {
        return {
          'success': false,
          'error': response.data['error'] ?? 'Failed to fetch documents',
        };
      }
    } on dio_lib.DioException catch (e) {
      return {'success': false, 'error': _handleDioError(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  /// Admin: Approve or reject a document
  ///
  /// Parameters:
  /// - [token]: Admin authentication bearer token
  /// - [verificationId]: ID of the verification record
  /// - [action]: 'approve' or 'reject'
  /// - [rejectionReason]: Reason if rejecting (optional)
  ///
  /// Returns: Response with updated status
  Future<Map<String, dynamic>> reviewDocument({
    required String token,
    required int verificationId,
    required String action,
    String? rejectionReason,
  }) async {
    try {
      final payload = {
        'action': action, // 'approve' or 'reject'
      };

      if (action == 'reject' && rejectionReason != null) {
        payload['rejection_reason'] = rejectionReason;
      }

      final response = await _dio.post(
        '$baseUrl/workers/documents/admin/$verificationId/',
        data: payload,
        options: dio_lib.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'] ?? {},
          'message':
              response.data['message'] ?? 'Document reviewed successfully',
        };
      } else {
        return {
          'success': false,
          'error': response.data['error'] ?? 'Failed to review document',
        };
      }
    } on dio_lib.DioException catch (e) {
      return {'success': false, 'error': _handleDioError(e)};
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: ${e.toString()}'};
    }
  }

  /// Handle Dio errors and return user-friendly message
  String _handleDioError(dio_lib.DioException error) {
    switch (error.type) {
      case dio_lib.DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case dio_lib.DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case dio_lib.DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case dio_lib.DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          return error.response?.data['error'] ?? 'Invalid request data';
        } else if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          return 'Permission denied.';
        } else if (statusCode == 404) {
          return 'Document not found.';
        } else if (statusCode == 413) {
          return 'Image file is too large. Maximum size is 5MB.';
        } else {
          return 'Server error: $statusCode';
        }
      case dio_lib.DioExceptionType.cancel:
        return 'Request was cancelled.';
      case dio_lib.DioExceptionType.unknown:
        return 'Network error occurred. Please try again.';
      default:
        return 'An error occurred: ${error.message}';
    }
  }
}
