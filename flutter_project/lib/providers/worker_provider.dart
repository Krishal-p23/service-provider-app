import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_role.dart';

class WorkerProvider extends ChangeNotifier {
  User? _currentWorker;
  final List<User> _registeredWorkers = []; // In-memory only - clears on app restart

  // Dummy workers for demonstration (hardcoded)
  static final List<User> _dummyWorkers = [
    User(
      name: 'Demo Worker',
      email: 'worker@demo.com',
      mobile: '9123456780',
      password: 'demo123',
      address: 'Mumbai Service Area',
      role: UserRole.worker,
    ),
    User(
      name: 'Test Service Provider',
      email: 'provider@test.com',
      mobile: '9123456781',
      password: 'test123',
      address: 'Delhi Service Area',
      role: UserRole.worker,
    ),
    User(
      name: 'Sample Technician',
      email: 'tech@sample.com',
      mobile: '9123456782',
      password: 'sample123',
      address: 'Bangalore Service Area',
      role: UserRole.worker,
    ),
  ];

  User? get currentWorker => _currentWorker;
  bool get isLoggedIn => _currentWorker != null;

  String get displayName => _currentWorker?.name ?? 'Worker';
  String get displayMobile => _currentWorker?.mobile ?? '';

  // Register new worker (in-memory only, clears on restart)
  Future<bool> register(User worker) async {
    // Ensure the role is worker
    if (worker.role != UserRole.worker) {
      return false;
    }

    // Check if worker already exists in dummy data
    if (_dummyWorkers.any((w) => w.email == worker.email || w.mobile == worker.mobile)) {
      return false; // Worker already exists in dummy data
    }

    // Check if worker already exists in registered workers
    if (_registeredWorkers.any((w) => w.email == worker.email || w.mobile == worker.mobile)) {
      return false; // Worker already exists
    }
    
    // Add to in-memory list (will be cleared on app restart)
    _registeredWorkers.add(worker);
    
    _currentWorker = worker;
    notifyListeners();
    return true;
  }

  // Login existing worker (checks both dummy and registered workers)
  Future<bool> login(String phoneOrEmail, String password) async {
    // First check dummy workers
    for (var worker in _dummyWorkers) {
      if ((worker.email == phoneOrEmail || worker.mobile == phoneOrEmail) &&
          worker.password == password &&
          worker.role == UserRole.worker) {
        _currentWorker = worker;
        notifyListeners();
        return true;
      }
    }

    // Then check registered workers
    for (var worker in _registeredWorkers) {
      if ((worker.email == phoneOrEmail || worker.mobile == phoneOrEmail) &&
          worker.password == password &&
          worker.role == UserRole.worker) {
        _currentWorker = worker;
        notifyListeners();
        return true;
      }
    }
    
    return false;
  }

  Future<void> logout() async {
    _currentWorker = null;
    notifyListeners();
  }

  void updateWorker(User worker) {
    if (_currentWorker != null && worker.role == UserRole.worker) {
      // Update in registered workers list
      final index = _registeredWorkers.indexWhere((w) => w.email == _currentWorker!.email);
      if (index != -1) {
        _registeredWorkers[index] = worker;
      }
      _currentWorker = worker;
      notifyListeners();
    }
  }

  void updateProfilePicture(String? imagePath) {
    if (_currentWorker != null) {
      final updatedWorker = _currentWorker!.copyWith(profilePicture: imagePath);
      updateWorker(updatedWorker);
    }
  }

  // Check if worker exists by email or mobile (checks both dummy and registered)
  bool workerExists(String phoneOrEmail) {
    // Check dummy workers
    if (_dummyWorkers.any(
      (worker) => (worker.email == phoneOrEmail || worker.mobile == phoneOrEmail) &&
                  worker.role == UserRole.worker,
    )) {
      return true;
    }
    // Check registered workers
    return _registeredWorkers.any(
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