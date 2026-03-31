import 'package:flutter/foundation.dart';
import '../models/worker.dart';
import '../models/service.dart';
import '../models/service_category.dart';
import '../models/user.dart';
import '../models/review.dart';
import '../services/api_service.dart';
import 'dart:math' show cos, sqrt, asin;

class ServiceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ServiceCategory> _categories = [];
  List<Service> _services = [];
  List<Worker> _workers = [];
  final Map<int, User> _workerUsers = {};
  final Map<int, double> _workerRatings = {};
  final Map<int, int> _workerReviewCounts = {};
  final Map<int, int> _workerCompletedJobs = {};
  final Map<int, List<int>> _workerServiceIds = {};
  final Map<int, List<Review>> _workerReviews = {};
  final Map<int, double?> _workerDistancesKm = {};
  bool _lastFetchUsedCoordinates = false;

  bool _isLoading = false;
  String? _error;

  List<ServiceCategory> get categories => _categories;
  List<Service> get services => _services;
  List<Worker> get workers => _workers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDistanceData => _workerDistancesKm.values.any((d) => d != null);
  bool get canSortByDistance => _lastFetchUsedCoordinates && hasDistanceData;

  ServiceProvider() {
    loadDataFromApi();
  }

  Future<void> loadDataFromApi({
    int? serviceId,
    int? categoryId,
    String? search,
    double? minRating,
    double? lat,
    double? lng,
    double radiusKm = 20,
  }) async {
    _isLoading = true;
    _error = null;
    _lastFetchUsedCoordinates = lat != null && lng != null;
    notifyListeners();

    try {
      await _apiService.initialize();

      final categoriesResponse = await _apiService.getServiceCategories();
      final servicesResponse = await _apiService.getServices();
      final workersResponse = await _apiService.getCustomerWorkers(
        serviceId: serviceId,
        categoryId: categoryId,
        search: search,
        minRating: minRating,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );

      if (categoriesResponse['success'] == true) {
        _categories = (categoriesResponse['data'] as List)
            .map(
              (item) => ServiceCategory.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      if (servicesResponse['success'] == true) {
        _services = (servicesResponse['data'] as List)
            .map((item) => Service.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (workersResponse['success'] == true) {
        _hydrateWorkers(workersResponse['data'] as List);
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load services/workers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _hydrateWorkers(List rawWorkers) {
    _workers = [];
    _workerUsers.clear();
    _workerRatings.clear();
    _workerReviewCounts.clear();
    _workerCompletedJobs.clear();
    _workerDistancesKm.clear();

    for (final item in rawWorkers) {
      final map = item as Map<String, dynamic>;
      final workerJson =
          map['worker'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final userJson =
          map['user'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final worker = Worker.fromJson(workerJson);
      _workers.add(worker);

      _workerUsers[worker.id] = User.fromJson({
        'id': userJson['id'] ?? worker.userId,
        'name': userJson['name'] ?? 'Worker ${worker.id}',
        'email': userJson['email'] ?? '',
        'phone': userJson['phone'] ?? '',
        'password_hash': '',
        'role': userJson['role'] ?? 'worker',
      });

      _workerRatings[worker.id] = ((map['rating'] ?? 0.0) as num).toDouble();
      _workerReviewCounts[worker.id] = (map['review_count'] ?? 0) as int;
      _workerCompletedJobs[worker.id] = (map['completed_jobs'] ?? 0) as int;
      final distanceRaw = map['distance_km'] ?? map['distance'];
      _workerDistancesKm[worker.id] = distanceRaw is num
          ? distanceRaw.toDouble()
          : double.tryParse(distanceRaw?.toString() ?? '');
    }

    // Build quick worker-service map from backend listing.
    _workerServiceIds
      ..clear()
      ..addEntries(_workers.map((w) => MapEntry(w.id, <int>[])));
  }

  // Get all service categories
  List<ServiceCategory> getAllCategories() {
    return _categories;
  }

  // Get services by category
  List<Service> getServicesByCategory(int categoryId) {
    return _services.where((s) => s.categoryId == categoryId).toList();
  }

  // Get available workers
  List<Worker> getAvailableWorkers() {
    return _workers.where((w) => w.isAvailable).toList();
  }

  // Get workers by service
  List<Worker> getWorkersByService(int serviceId) {
    final explicitMatches = _workerServiceIds.entries
        .where((entry) => entry.value.contains(serviceId))
        .map((entry) => entry.key)
        .toSet();

    if (explicitMatches.isNotEmpty) {
      return _workers
          .where((w) => explicitMatches.contains(w.id) && w.isAvailable)
          .toList();
    }

    // If mapping isn't hydrated yet, keep list functional by returning available workers.
    return getAvailableWorkers();
  }

  // Search workers by query
  List<Worker> searchWorkers(String query) {
    if (query.isEmpty) return getAvailableWorkers();

    final lowercaseQuery = query.toLowerCase();
    return getAvailableWorkers().where((worker) {
      // Search in worker bio
      final bio = worker.bio?.toLowerCase() ?? '';

      // Get user details for worker
      final user = _workerUsers[worker.id];
      final name = user?.name.toLowerCase() ?? '';

      return bio.contains(lowercaseQuery) || name.contains(lowercaseQuery);
    }).toList();
  }

  Future<void> fetchWorkers({
    int? serviceId,
    int? categoryId,
    String? search,
    double? minRating,
    double? lat,
    double? lng,
    double radiusKm = 20,
  }) async {
    _isLoading = true;
    _error = null;
    _lastFetchUsedCoordinates = lat != null && lng != null;
    notifyListeners();

    try {
      await _apiService.initialize();
      final workersResponse = await _apiService.getCustomerWorkers(
        serviceId: serviceId,
        categoryId: categoryId,
        search: search,
        minRating: minRating,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );

      if (workersResponse['success'] == true) {
        _hydrateWorkers(workersResponse['data'] as List);
      }
    } catch (e) {
      _error = 'Failed to fetch workers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate distance between two coordinates (in km)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // PI / 180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  int _compareNullableDistanceAsc(double? a, double? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  // Get workers sorted by distance
  List<Map<String, dynamic>> getWorkersByDistance(
    int userId, {
    int? serviceId,
  }) {
    List<Worker> workerList = serviceId != null
        ? getWorkersByService(serviceId)
        : getAvailableWorkers();

    List<Map<String, dynamic>> workersWithDistance = [];

    for (var worker in workerList) {
      final distance = _workerDistancesKm[worker.id];
      final rating = _workerRatings[worker.id] ?? 0.0;

      workersWithDistance.add({
        'worker': worker,
        'distance': distance,
        'rating': rating,
      });
    }

    // Sort by distance
    workersWithDistance.sort(
      (a, b) => _compareNullableDistanceAsc(
        a['distance'] as double?,
        b['distance'] as double?,
      ),
    );

    return workersWithDistance;
  }

  // Get workers sorted by rating
  List<Map<String, dynamic>> getWorkersByRating(int userId, {int? serviceId}) {
    final workersWithDistance = getWorkersByDistance(
      userId,
      serviceId: serviceId,
    );

    // Sort by rating (descending), then by distance
    workersWithDistance.sort((a, b) {
      final ratingCompare = b['rating'].compareTo(a['rating']);
      if (ratingCompare != 0) return ratingCompare;
      return _compareNullableDistanceAsc(
        a['distance'] as double?,
        b['distance'] as double?,
      );
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
        workersData = workersData.where((w) => w['distance'] != null).toList();
        workersData.sort(
          (a, b) => _compareNullableDistanceAsc(
            a['distance'] as double?,
            b['distance'] as double?,
          ),
        );
        break;
      case 'distance_desc':
        workersData = workersData.where((w) => w['distance'] != null).toList();
        workersData.sort(
          (a, b) => _compareNullableDistanceAsc(
            b['distance'] as double?,
            a['distance'] as double?,
          ),
        );
        break;
      case 'rating':
        workersData.sort((a, b) {
          final ratingCompare = b['rating'].compareTo(a['rating']);
          if (ratingCompare != 0) return ratingCompare;
          return _compareNullableDistanceAsc(
            a['distance'] as double?,
            b['distance'] as double?,
          );
        });
        break;
    }

    return workersData;
  }

  // Get worker details with user info
  Map<String, dynamic>? getWorkerDetails(int workerId, int userId) {
    Worker? worker;
    try {
      worker = _workers.firstWhere((w) => w.id == workerId);
    } catch (_) {
      worker = null;
    }
    if (worker == null) return null;

    final user = _workerUsers[workerId];
    final reviews = _workerReviews[workerId] ?? <Review>[];
    final rating = _workerRatings[workerId] ?? 0.0;
    final reviewCount = _workerReviewCounts[workerId] ?? reviews.length;
    final workerServices = _services;

    return {
      'worker': worker,
      'user': user,
      'rating': rating,
      'reviewCount': reviewCount,
      'reviews': reviews,
      'services': workerServices,
      'distance': _workerDistancesKm[workerId],
      'completedJobs': _workerCompletedJobs[workerId] ?? 0,
    };
  }

  Future<Map<String, dynamic>?> fetchWorkerDetails(
    int workerId,
    int userId,
  ) async {
    try {
      final result = await _apiService.getWorkerDetails(workerId);
      if (result['success'] != true) {
        return getWorkerDetails(workerId, userId);
      }

      final data = result['data'] as Map<String, dynamic>;
      final workerJson =
          data['worker'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final userJson =
          data['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final servicesJson = data['services'] as List? ?? <dynamic>[];
      final reviewsJson = data['reviews'] as List? ?? <dynamic>[];

      final worker = Worker.fromJson(workerJson);
      final user = User.fromJson({
        'id': userJson['id'] ?? worker.userId,
        'name': userJson['name'] ?? 'Worker ${worker.id}',
        'email': userJson['email'] ?? '',
        'phone': userJson['phone'] ?? '',
        'password_hash': '',
        'role': userJson['role'] ?? 'worker',
      });

      final workerServices = servicesJson
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList();
      final reviews = reviewsJson
          .map((item) => Review.fromJson(item as Map<String, dynamic>))
          .toList();

      _workerUsers[worker.id] = user;
      _workerRatings[worker.id] = ((data['rating'] ?? 0.0) as num).toDouble();
      _workerReviewCounts[worker.id] =
          (data['review_count'] ?? reviews.length) as int;
      _workerCompletedJobs[worker.id] = (data['completed_jobs'] ?? 0) as int;
        final distanceRaw = data['distance_km'] ?? data['distance'];
        _workerDistancesKm[worker.id] = distanceRaw is num
          ? distanceRaw.toDouble()
          : double.tryParse(distanceRaw?.toString() ?? '');
      _workerReviews[worker.id] = reviews;

      final existingIndex = _workers.indexWhere((w) => w.id == worker.id);
      if (existingIndex >= 0) {
        _workers[existingIndex] = worker;
      } else {
        _workers.add(worker);
      }

      notifyListeners();

      return {
        'worker': worker,
        'user': user,
        'rating': _workerRatings[worker.id] ?? 0.0,
        'reviewCount': _workerReviewCounts[worker.id] ?? reviews.length,
        'reviews': reviews,
        'services': workerServices,
        'distance': _workerDistancesKm[worker.id],
        'completedJobs': _workerCompletedJobs[worker.id] ?? 0,
      };
    } catch (_) {
      return getWorkerDetails(workerId, userId);
    }
  }

  // Get service by ID
  Service? getServiceById(int serviceId) {
    try {
      return _services.firstWhere((s) => s.id == serviceId);
    } catch (_) {
      return null;
    }
  }

  // Get category by ID
  ServiceCategory? getCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  Worker? getWorkerById(int workerId) {
    try {
      return _workers.firstWhere((w) => w.id == workerId);
    } catch (_) {
      return null;
    }
  }

  User? getWorkerUserByWorkerId(int workerId) {
    return _workerUsers[workerId];
  }

  String getWorkerName(int workerId) {
    return _workerUsers[workerId]?.name ?? 'Worker $workerId';
  }

  int getWorkerCompletedJobs(int workerId) {
    return _workerCompletedJobs[workerId] ?? 0;
  }

  double getWorkerRating(int workerId) {
    return _workerRatings[workerId] ?? 0.0;
  }

  List<Review> getWorkerReviews(int workerId) {
    return _workerReviews[workerId] ?? <Review>[];
  }

  // Check if a booking has been reviewed
  bool hasReviewForBooking(int bookingId) {
    for (final reviews in _workerReviews.values) {
      for (final review in reviews) {
        if (review.bookingId == bookingId) {
          return true;
        }
      }
    }
    return false;
  }

  // Get review for a specific booking
  Review? getReviewForBooking(int bookingId) {
    for (final reviews in _workerReviews.values) {
      for (final review in reviews) {
        if (review.bookingId == bookingId) {
          return review;
        }
      }
    }
    return null;
  }

  // Add review for worker
  Future<void> addReview({
    required int bookingId,
    required int userId,
    required int workerId,
    required int rating,
    String? comment,
  }) async {
    await _apiService.initialize();
    final response = await _apiService.createReview(
      bookingId: bookingId,
      userId: userId,
      workerId: workerId,
      rating: rating,
      comment: comment,
    );

    if (response['success'] != true) {
      final message =
          response['message']?.toString() ?? 'Failed to submit review';
      throw Exception(message);
    }

    final review = Review.fromJson(response['data'] as Map<String, dynamic>);
    final existing = _workerReviews[workerId] ?? <Review>[];
    _workerReviews[workerId] = [review, ...existing];
    _workerReviewCounts[workerId] = (_workerReviewCounts[workerId] ?? 0) + 1;
    final allRatings = _workerReviews[workerId]!.map((r) => r.rating).toList();
    if (allRatings.isNotEmpty) {
      _workerRatings[workerId] =
          allRatings.reduce((a, b) => a + b) / allRatings.length;
    }

    notifyListeners();
  }
}
