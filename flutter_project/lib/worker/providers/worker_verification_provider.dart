// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class WorkerVerificationProvider extends ChangeNotifier {
//   bool _isVerified = false;
//   String _governmentId = '';
//   String _idImagePath = '';

//   bool get isVerified => _isVerified;
//   String get governmentId => _governmentId;
//   String get idImagePath => _idImagePath;

//   WorkerVerificationProvider() {
//     _loadVerificationStatus();
//   }

//   Future<void> _loadVerificationStatus() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       _isVerified = prefs.getBool('worker_verified') ?? false;
//       _governmentId = prefs.getString('worker_gov_id') ?? '';
//       _idImagePath = prefs.getString('worker_id_image') ?? '';
//       notifyListeners();
//     } catch (e) {
//       // If shared_preferences fails, keep default values
//       _isVerified = false;
//     }
//   }

//   Future<bool> submitVerification(String govId, String imagePath) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('worker_verified', true);
//       await prefs.setString('worker_gov_id', govId);
//       await prefs.setString('worker_id_image', imagePath);
      
//       _isVerified = true;
//       _governmentId = govId;
//       _idImagePath = imagePath;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<void> clearVerification() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('worker_verified');
//       await prefs.remove('worker_gov_id');
//       await prefs.remove('worker_id_image');
      
//       _isVerified = false;
//       _governmentId = '';
//       _idImagePath = '';
//       notifyListeners();
//     } catch (e) {
//       // Ignore errors
//     }
//   }
// }






import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerVerificationProvider extends ChangeNotifier {
  bool _isVerified = false;
  bool _isPending = false;
  String _governmentId = '';
  String _idImagePath = '';

  bool get isVerified => _isVerified;
  bool get isPending => _isPending;
  String get governmentId => _governmentId;
  String get idImagePath => _idImagePath;

  WorkerVerificationProvider() {
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isVerified = prefs.getBool('worker_verified') ?? false;
      _isPending = prefs.getBool('worker_pending') ?? false;
      _governmentId = prefs.getString('worker_gov_id') ?? '';
      _idImagePath = prefs.getString('worker_id_image') ?? '';
      notifyListeners();
    } catch (e) {
      // If shared_preferences fails, keep default values
      _isVerified = false;
      _isPending = false;
    }
  }

  Future<bool> submitVerification(String govId, String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Set as PENDING, NOT verified
      await prefs.setBool('worker_verified', false);
      await prefs.setBool('worker_pending', true);
      await prefs.setString('worker_gov_id', govId);
      await prefs.setString('worker_id_image', imagePath);
      
      _isVerified = false;
      _isPending = true;
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

  Future<void> clearVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('worker_verified');
      await prefs.remove('worker_pending');
      await prefs.remove('worker_gov_id');
      await prefs.remove('worker_id_image');
      
      _isVerified = false;
      _isPending = false;
      _governmentId = '';
      _idImagePath = '';
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }
}