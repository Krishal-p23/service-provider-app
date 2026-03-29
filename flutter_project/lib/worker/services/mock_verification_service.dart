import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mock verification service for offline/demo verification
/// Stores images locally and returns random verification status
/// No backend API calls - completely local
class MockVerificationService {
  static const String _verificationStatusKey = 'mock_verification_status';
  static const String _verificationResultKey = 'mock_verification_result';
  static const String _verificationTimestampKey = 'mock_verification_timestamp';
  static const String _documentTypeKey = 'mock_document_type';
  static const String _documentNumberKey = 'mock_document_number';

  /// Verify document locally with random result
  ///
  /// Parameters:
  /// - [documentType]: Type of document (aadhar, pan, driving_license, etc)
  /// - [documentNumber]: Document ID number
  /// - [imagePath]: Path to image file
  ///
  /// Returns: Map containing verification result
  static Future<Map<String, dynamic>> verifyDocument({
    required String documentType,
    required String documentNumber,
    required String imagePath,
  }) async {
    try {
      print(
        '[MockVerification] Starting verification: type=$documentType, number=$documentNumber',
      );
      print('[MockVerification] Image path: $imagePath');

      // Copy image to app documents for storage
      final storedImagePath = await _copyImageToAppDocuments(
        imagePath,
        documentType,
      );
      print('[MockVerification] Image stored at: $storedImagePath');

      // Generate random verification result
      final isVerified = Random().nextBool();
      print(
        '[MockVerification] Random result: ${isVerified ? 'VERIFIED' : 'UNVERIFIED'}',
      );

      // Save verification details to SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Store verification status
      await prefs.setBool(_verificationStatusKey, true); // Marked as submitted
      await prefs.setBool(_verificationResultKey, isVerified); // Random result
      await prefs.setString(
        _verificationTimestampKey,
        DateTime.now().toIso8601String(),
      );
      await prefs.setString(_documentTypeKey, documentType);
      await prefs.setString(_documentNumberKey, documentNumber);

      // Also store the image path
      await prefs.setString('worker_id_image', storedImagePath);
      await prefs.setString('worker_doc_type', documentType);
      await prefs.setString('worker_gov_id', documentNumber);

      print('[MockVerification] Verification data saved to SharedPreferences');

      return {
        'success': true,
        'data': {
          'document_type': documentType,
          'document_type_display': _getDocumentTypeDisplay(documentType),
          'document_number': documentNumber,
          'document_image': storedImagePath,
          'status': isVerified ? 'verified' : 'unverified',
          'status_display': isVerified ? 'Verified' : 'Unverified',
          'is_verified': isVerified,
          'is_pending': false,
          'is_rejected': !isVerified,
          'verified_at': isVerified ? DateTime.now().toIso8601String() : null,
          'rejection_reason': !isVerified
              ? 'Mock verification - Document not verified. Please resubmit.'
              : '',
        },
        'message': isVerified
            ? 'Your document has been verified!'
            : 'Your document could not be verified. Please resubmit.',
      };
    } catch (e) {
      print('[MockVerification] Error during verification: ${e.toString()}');
      return {
        'success': false,
        'error': 'Error during verification: ${e.toString()}',
      };
    }
  }

  /// Copy image file to app documents directory
  static Future<String> _copyImageToAppDocuments(
    String imagePath,
    String documentType,
  ) async {
    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final verificationDir = Directory('${appDir.path}/verification_images');

      // Create directory if it doesn't exist
      if (!await verificationDir.exists()) {
        await verificationDir.create(recursive: true);
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename =
          '${documentType}_$timestamp.${imagePath.split('.').last}';
      final destinationPath = '${verificationDir.path}/$filename';

      // Copy file
      final sourceFile = File(imagePath);
      await sourceFile.copy(destinationPath);

      print('[MockVerification] Image copied to: $destinationPath');
      return destinationPath;
    } catch (e) {
      print('[MockVerification] Error copying image: ${e.toString()}');
      rethrow;
    }
  }

  /// Get stored verification status
  static Future<Map<String, dynamic>> getVerificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if verification was submitted
      final isSubmitted = prefs.getBool(_verificationStatusKey) ?? false;

      if (!isSubmitted) {
        return {
          'success': true,
          'hasDocument': false,
          'message': 'No documents submitted yet',
        };
      }

      // Get stored verification details
      final isVerified = prefs.getBool(_verificationResultKey) ?? false;
      final timestamp = prefs.getString(_verificationTimestampKey);
      final documentType = prefs.getString(_documentTypeKey);
      final documentNumber = prefs.getString(_documentNumberKey);
      final imagePath = prefs.getString('worker_id_image');

      return {
        'success': true,
        'hasDocument': true,
        'documentType': documentType,
        'documentTypeDisplay': _getDocumentTypeDisplay(documentType),
        'documentNumber': documentNumber,
        'documentImage': imagePath,
        'status': isVerified ? 'verified' : 'unverified',
        'statusDisplay': isVerified ? 'Verified' : 'Unverified',
        'isVerified': isVerified,
        'isPending': false,
        'isRejected': !isVerified,
        'rejectionReason': !isVerified
            ? 'Mock verification - Document not verified.'
            : '',
        'createdAt': timestamp,
        'verifiedAt': isVerified ? timestamp : null,
      };
    } catch (e) {
      print('[MockVerification] Error getting status: ${e.toString()}');
      return {
        'success': false,
        'error': 'Error retrieving verification status: ${e.toString()}',
      };
    }
  }

  /// Clear stored verification data
  static Future<void> clearVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_verificationStatusKey);
      await prefs.remove(_verificationResultKey);
      await prefs.remove(_verificationTimestampKey);
      await prefs.remove(_documentTypeKey);
      await prefs.remove(_documentNumberKey);
      await prefs.remove('worker_id_image');
      await prefs.remove('worker_doc_type');
      await prefs.remove('worker_gov_id');

      print('[MockVerification] Verification data cleared');
    } catch (e) {
      print('[MockVerification] Error clearing data: ${e.toString()}');
    }
  }

  /// Get display name for document type
  static String _getDocumentTypeDisplay(String? docType) {
    return switch (docType) {
      'aadhar' => 'Aadhar Card',
      'pan' => 'PAN Card',
      'driving_license' => 'Driving License',
      'passport' => 'Passport',
      'voter_id' => 'Voter ID',
      _ => 'Government ID',
    };
  }
}
