import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/user_role.dart';

class WorkerProvider extends ChangeNotifier {
  User? _currentWorker;
  final Map<String, User> _registeredWorkers = {}; // Worker database
  bool _isInitialized = false;

  User? get currentWorker => _currentWorker;
  bool get isLoggedIn => _currentWorker != null;
  bool get isInitialized => _isInitialized;

  String get displayName => _currentWorker?.name ?? 'Worker';
  String get displayMobile => _currentWorker?.mobile ?? '';

  // Initialize and check for saved worker session
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final workerJson = prefs.getString('current_worker');
    final workersJson = prefs.getString('registered_workers');

    // Load registered workers
    if (workersJson != null) {
      final Map<String, dynamic> workersMap = json.decode(workersJson);
      _registeredWorkers.clear();
      workersMap.forEach((key, value) {
        _registeredWorkers[key] = User.fromJson(value);
      });
    }

    // Load current worker session
    if (workerJson != null) {
      _currentWorker = User.fromJson(json.decode(workerJson));
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Save registered workers to storage
  Future<void> _saveRegisteredWorkers() async {
    final prefs = await SharedPreferences.getInstance();
    final workersMap = <String, dynamic>{};
    _registeredWorkers.forEach((key, value) {
      workersMap[key] = value.toJson();
    });
    await prefs.setString('registered_workers', json.encode(workersMap));
  }

  // Save current worker session
  Future<void> _saveCurrentWorker() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentWorker != null) {
      await prefs.setString('current_worker', json.encode(_currentWorker!.toJson()));
    } else {
      await prefs.remove('current_worker');
    }
  }

  // Register new worker
  Future<bool> register(User worker) async {
    // Ensure the role is worker
    if (worker.role != UserRole.worker) {
      return false;
    }

    // Check if worker already exists
    if (_registeredWorkers.containsKey(worker.email)) {
      return false; // Worker already exists
    }
    
    _registeredWorkers[worker.email] = worker;
    await _saveRegisteredWorkers();
    
    _currentWorker = worker;
    await _saveCurrentWorker();
    
    notifyListeners();
    return true;
  }

  // Login existing worker
  Future<bool> login(String phoneOrEmail, String password) async {
    // Try to find worker by phone or email
    User? foundWorker;
    
    for (var worker in _registeredWorkers.values) {
      if ((worker.email == phoneOrEmail || worker.mobile == phoneOrEmail) &&
          worker.password == password &&
          worker.role == UserRole.worker) {
        foundWorker = worker;
        break;
      }
    }

    if (foundWorker != null) {
      _currentWorker = foundWorker;
      await _saveCurrentWorker();
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<void> logout() async {
    _currentWorker = null;
    await _saveCurrentWorker();
    notifyListeners();
  }

  void updateWorker(User worker) {
    if (_currentWorker != null && worker.role == UserRole.worker) {
      // Update in registered workers map
      _registeredWorkers[_currentWorker!.email] = worker;
      _currentWorker = worker;
      _saveRegisteredWorkers();
      _saveCurrentWorker();
      notifyListeners();
    }
  }

  void updateProfilePicture(String? imagePath) {
    if (_currentWorker != null) {
      final updatedWorker = _currentWorker!.copyWith(profilePicture: imagePath);
      updateWorker(updatedWorker);
    }
  }

  // Check if worker exists by email or mobile
  bool workerExists(String phoneOrEmail) {
    return _registeredWorkers.values.any(
      (worker) => (worker.email == phoneOrEmail || worker.mobile == phoneOrEmail) &&
                  worker.role == UserRole.worker,
    );
  }

  // Worker-specific data (can be expanded)
  int get todayJobsCount => 0; // TODO: Implement real job counting
  int get weekJobsCount => 0; // TODO: Implement real job counting
  double get totalEarnings => 0.0; // TODO: Implement real earnings tracking
  double get averageRating => 0.0; // TODO: Implement real rating calculation
}