import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/worker_verification_api_service.dart';
import '../../customer/services/api_service.dart';

class WorkerVerificationProvider extends ChangeNotifier {
  bool _isVerified = false;
  bool _isPending = false;
  String _documentType = 'aadhar';
  String _governmentId = '';
  String _idImagePath = '';
  String? _lastError;

  final WorkerVerificationApiService _apiService =
      WorkerVerificationApiService();
  final ApiService _authService = ApiService();

  bool get isVerified => _isVerified;
  bool get isPending => _isPending;
  String get documentType => _documentType;
  String get governmentId => _governmentId;
  String get idImagePath => _idImagePath;
  String? get lastError => _lastError;

  WorkerVerificationProvider() {
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isVerified = prefs.getBool('worker_verified') ?? false;
      _isPending = prefs.getBool('worker_pending') ?? false;
      _documentType = prefs.getString('worker_doc_type') ?? 'aadhar';
      _governmentId = prefs.getString('worker_gov_id') ?? '';
      _idImagePath = prefs.getString('worker_id_image') ?? '';
      notifyListeners();
    } catch (e) {
      // If shared_preferences fails, keep default values
      _isVerified = false;
      _isPending = false;
      _documentType = 'aadhar';
    }
  }

  Future<bool> submitVerification(
    String documentType,
    String govId,
    String imagePath,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Set as PENDING, NOT verified
      await prefs.setBool('worker_verified', false);
      await prefs.setBool('worker_pending', true);
      await prefs.setString('worker_doc_type', documentType);
      await prefs.setString('worker_gov_id', govId);
      await prefs.setString('worker_id_image', imagePath);

      _isVerified = false;
      _isPending = true;
      _documentType = documentType;
      _governmentId = govId;
      _idImagePath = imagePath;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // This would be called by admin/backend to approve verification
  Future<void> approveVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('worker_verified', true);
      await prefs.setBool('worker_pending', false);

      _isVerified = true;
      _isPending = false;
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }

  /// Submit document verification to backend API
  ///
  /// Parameters:
  /// - [documentType]: Type of document (aadhar, pan, driving_license, passport, voter_id)
  /// - [govId]: Government ID number
  /// - [imagePath]: Path to image file
  ///
  /// Returns: true if successful, false otherwise
  Future<bool> submitVerificationViaAPI({
    required String documentType,
    required String govId,
    required String imagePath,
  }) async {
    try {
      await _authService.initialize();
      final token = _authService.accessToken;

      if (token == null) {
        _lastError = 'Not authenticated. Please login again.';
        notifyListeners();
        return false;
      }

      final result = await _apiService.uploadDocument(
        token: token,
        documentType: documentType,
        documentNumber: govId,
        imagePath: imagePath,
      );

      if (result['success'] == true) {
        // Upload succeeds first as pending; verification may happen later.
        _documentType = documentType;
        _governmentId = govId;
        _idImagePath = imagePath;
        _isVerified = false;
        _isPending = true;
        _lastError = null;
        notifyListeners();
        return true;
      } else {
        _lastError = result['error'] ?? 'Failed to upload document';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _lastError = 'Error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Fetch verification status from backend API
  Future<void> fetchVerificationStatusFromAPI() async {
    try {
      await _authService.initialize();
      final token = _authService.accessToken;

      if (token == null) {
        _lastError = 'Not authenticated';
        notifyListeners();
        return;
      }

      final result = await _apiService.getVerificationStatus(token: token);

      if (result['success'] == true) {
        if (result['hasDocument'] == true) {
          _documentType = result['documentType'] ?? 'aadhar';
          _governmentId = result['documentNumber'] ?? '';
          _idImagePath = result['documentImage'] ?? '';
          _isVerified = result['isVerified'] ?? false;
          _isPending = result['isPending'] ?? false;
          _lastError = null;
        } else {
          _isVerified = false;
          _isPending = false;
          _documentType = 'aadhar';
          _governmentId = '';
          _idImagePath = '';
        }
        notifyListeners();
      } else {
        _lastError = result['error'] ?? 'Failed to fetch status';
        notifyListeners();
      }
    } catch (e) {
      _lastError = 'Error: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> clearVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('worker_verified');
      await prefs.remove('worker_pending');
      await prefs.remove('worker_doc_type');
      await prefs.remove('worker_gov_id');
      await prefs.remove('worker_id_image');

      _isVerified = false;
      _isPending = false;
      _documentType = 'aadhar';
      _governmentId = '';
      _idImagePath = '';
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }
}
