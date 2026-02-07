import 'package:flutter/foundation.dart';
import '../models/worker.dart';
import '../models/service.dart';
import '../models/service_category.dart';
// import '../models/worker_service.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../models/user_location.dart';
import '../utils/mock_data.dart';
import 'dart:math' show cos, sqrt, asin;

class ServiceProvider with ChangeNotifier {
  List<ServiceCategory> _categories = [];
  List<Service> _services = [];
  List<Worker> _workers = [];
  
  List<ServiceCategory> get categories => _categories;
  List<Service> get services => _services;
  List<Worker> get workers => _workers;

  ServiceProvider() {
    _loadData();
  }

  void _loadData() {
    _categories = MockDatabase.categories;
    _services = MockDatabase.services;
    _workers = MockDatabase.workers;
    notifyListeners();
  }

  // Get all service categories
  List<ServiceCategory> getAllCategories() {
    return _categories;
  }

  // Get services by category
  List<Service> getServicesByCategory(int categoryId) {
    return MockDatabase.getServicesByCategoryId(categoryId);
  }

  // Get available workers
  List<Worker> getAvailableWorkers() {
    return MockDatabase.getAvailableWorkers();
  }

  // Get workers by service
  List<Worker> getWorkersByService(int serviceId) {
    // Get worker IDs that provide this service
    final workerServiceLinks = MockDatabase.workerServices
        .where((ws) => ws.serviceId == serviceId)
        .toList();
    
    final workerIds = workerServiceLinks.map((ws) => ws.workerId).toSet();
    
    // Get workers
    return _workers.where((w) => workerIds.contains(w.id) && w.isAvailable).toList();
  }

  // Search workers by query
  List<Worker> searchWorkers(String query) {
    if (query.isEmpty) return getAvailableWorkers();
    
    final lowercaseQuery = query.toLowerCase();
    return getAvailableWorkers().where((worker) {
      // Search in worker bio
      final bio = worker.bio?.toLowerCase() ?? '';
      
      // Get user details for worker
      final user = MockDatabase.getUserById(worker.userId);
      final name = user?.name.toLowerCase() ?? '';
      
      return bio.contains(lowercaseQuery) || name.contains(lowercaseQuery);
    }).toList();
  }

  // Calculate distance between two coordinates (in km)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Get workers sorted by distance
  List<Map<String, dynamic>> getWorkersByDistance(int userId, {int? serviceId}) {
    List<Worker> workerList = serviceId != null 
        ? getWorkersByService(serviceId)
        : getAvailableWorkers();
    
    // Get user location
    final userLocation = MockDatabase.getUserLocation(userId);
    if (userLocation == null) {
      // If no user location, return workers with 0 distance
      return workerList.map((w) => {
        'worker': w,
        'distance': 0.0,
        'rating': MockDatabase.getWorkerAverageRating(w.id),
      }).toList();
    }

    // Calculate distances
    List<Map<String, dynamic>> workersWithDistance = [];
    
    for (var worker in workerList) {
      // For mock purposes, generate random distance (1-10 km)
      // In real app, fetch worker location from database
      final distance = (worker.id % 10) + 1.0;
      final rating = MockDatabase.getWorkerAverageRating(worker.id);
      
      workersWithDistance.add({
        'worker': worker,
        'distance': distance,
        'rating': rating,
      });
    }

    // Sort by distance
    workersWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));
    
    return workersWithDistance;
  }

  // Get workers sorted by rating
  List<Map<String, dynamic>> getWorkersByRating(int userId, {int? serviceId}) {
    final workersWithDistance = getWorkersByDistance(userId, serviceId: serviceId);
    
    // Sort by rating (descending), then by distance
    workersWithDistance.sort((a, b) {
      final ratingCompare = b['rating'].compareTo(a['rating']);
      if (ratingCompare != 0) return ratingCompare;
      return a['distance'].compareTo(b['distance']);
    });
    
    return workersWithDistance;
  }

  // Filter workers
  List<Map<String, dynamic>> filterWorkers({
    required int userId,
    int? serviceId,
    String sortBy = 'distance', // 'distance', 'distance_desc', 'rating'
    double? minRating,
  }) {
    var workersData = getWorkersByDistance(userId, serviceId: serviceId);
    
    // Apply rating filter
    if (minRating != null) {
      workersData = workersData.where((w) => w['rating'] >= minRating).toList();
    }
    
    // Apply sorting
    switch (sortBy) {
      case 'distance':
        workersData.sort((a, b) => a['distance'].compareTo(b['distance']));
        break;
      case 'distance_desc':
        workersData.sort((a, b) => b['distance'].compareTo(a['distance']));
        break;
      case 'rating':
        workersData.sort((a, b) {
          final ratingCompare = b['rating'].compareTo(a['rating']);
          if (ratingCompare != 0) return ratingCompare;
          return a['distance'].compareTo(b['distance']);
        });
        break;
    }
    
    return workersData;
  }

  // Get worker details with user info
  Map<String, dynamic>? getWorkerDetails(int workerId, int userId) {
    final worker = MockDatabase.getWorkerById(workerId);
    if (worker == null) return null;
    
    final user = MockDatabase.getUserById(worker.userId);
    final reviews = MockDatabase.getReviewsByWorkerId(workerId);
    final rating = MockDatabase.getWorkerAverageRating(workerId);
    
    // Get worker services
    final workerServiceLinks = MockDatabase.workerServices
        .where((ws) => ws.workerId == workerId)
        .toList();
    final serviceIds = workerServiceLinks.map((ws) => ws.serviceId).toSet();
    final workerServices = _services.where((s) => serviceIds.contains(s.id)).toList();
    
    // Calculate distance
    final userLocation = MockDatabase.getUserLocation(userId);
    double distance = (workerId % 10) + 1.0; // Mock distance
    
    return {
      'worker': worker,
      'user': user,
      'rating': rating,
      'reviewCount': reviews.length,
      'reviews': reviews,
      'services': workerServices,
      'distance': distance,
      'completedJobs': reviews.length, // Mock: using review count as completed jobs
    };
  }

  // Get service by ID
  Service? getServiceById(int serviceId) {
    return MockDatabase.getServiceById(serviceId);
  }

  // Get category by ID
  ServiceCategory? getCategoryById(int categoryId) {
    return MockDatabase.getCategoryById(categoryId);
  }

  // Add review for worker
  Future<void> addReview({
    required int bookingId,
    required int userId,
    required int workerId,
    required int rating,
    String? comment,
  }) async {
    final reviewId = MockDatabase.generateId(MockDatabase.reviews);
    
    final review = Review(
      id: reviewId,
      bookingId: bookingId,
      userId: userId,
      workerId: workerId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    MockDatabase.addReview(review);
    notifyListeners();
  }
}